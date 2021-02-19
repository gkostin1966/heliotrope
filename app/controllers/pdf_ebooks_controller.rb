# frozen_string_literal: true

class PdfEbooksController < CheckpointController
  include Watermark::Watermarkable
  protect_from_forgery except: :file

  def show
    id = params[:id]
    pdf_ebook = Sighrax.from_noid(id)
    policy = PdfEbookPolicy.new(current_actor, pdf_ebook)
    policy.authorize! :show?

    @presenter = Sighrax.hyrax_presenter(pdf_ebook, current_ability)
    @parent_presenter = Sighrax.hyrax_presenter(pdf_ebook.parent, current_ability)
    @title = @presenter.parent.present? ? @presenter.parent.page_title : @presenter.page_title
    @citable_link = @parent_presenter.citable_link
    @back_link = if params[:publisher].present?
                   URI.join(main_app.root_url, params[:publisher]).to_s
                 else
                   @presenter.parent.catalog_url
                 end
    @ebook_download_presenter = EBookDownloadPresenter.new(@parent_presenter, current_ability, current_actor)

    CounterService.from(self, @presenter).count(request: 1)

    render layout: false
  end

  def download
    id = params[:id] # file_set ID
    pdf = Sighrax.from_noid(id) # Sighrax::PortableDocumentFormat
    # pdf.parent # Monograph; goes to solr based on monograph_id_ssim

    policy = PdfEbookPolicy.new(current_actor, pdf)
    policy.authorize! :download?

    do_download
  end

  def file
    id = params[:id]
    pdf_ebook = Sighrax.from_noid(id)
    policy = PdfEbookPolicy.new(current_actor, pdf_ebook)
    return head :no_content unless policy.show?

    pdf = UnpackService.root_path_from_noid(pdf_ebook.noid, 'pdf_ebook') + ".pdf"
    if File.exist? pdf
      response.headers['Accept-Ranges'] = 'bytes'
      pdf.gsub!(/releases\/\d+/, "current")
      response.headers['X-Sendfile'] = pdf
      send_file pdf
    else
      # This really should *never* happen, but might if the pdf wasn't unpacked right...
      # Consider this an error. We don't want to go through ActiveFedora for this.
      Rails.logger.error("[PDF EBOOK ERROR] The pdf_ebook #{pdf} is not in the derivative directory!!!!")
      @presenter = Sighrax.hyrax_presenter(pdf_ebook, current_ability)
      response.headers['Content-Length'] ||= @presenter.file.size.to_s
      # Prevent Rack::ETag from calculating a digest over body with a Last-Modified response header
      # any Solr document save will change this, see definition of browser_cache_breaker
      response.headers['Cache-Control'] = 'max-age=31536000, private'
      response.headers['Last-Modified'] = Time.new(@presenter.browser_cache_breaker).utc.strftime("%a, %d %b %Y %T GMT")
      send_data @presenter.file.content, filename: @presenter.label, type: "application/pdf", disposition: "inline"
    end
  rescue StandardError => e
    Rails.logger.info("PdfEbooksController.file raised #{e}")
    head :no_content
  end

  private

    def do_download
    end
end
