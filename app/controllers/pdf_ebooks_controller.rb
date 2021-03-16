# frozen_string_literal: true

class PdfEbooksController < CheckpointController
  include Watermark::Watermarkable

  before_action :setup
  protect_from_forgery except: :file

  def show
    @policy.authorize! :show?

    @presenter = Sighrax.hyrax_presenter(@pdf_ebook, current_ability)
    @parent_presenter = Sighrax.hyrax_presenter(@pdf_ebook.parent, current_ability)
    @title = @presenter.parent.present? ? @presenter.parent.page_title : @presenter.page_title
    @citable_link = @parent_presenter.citable_link
    @back_link = if params[:publisher].present?
                   URI.join(main_app.root_url, params[:publisher]).to_s
                 else
                   @presenter.parent.catalog_url
                 end
    @ebook_download_presenter = EbookDownloadPresenter.new(@parent_presenter, current_ability, current_actor)

    CounterService.from(self, @presenter).count(request: 1)

    render layout: false
  end

  def file
    @policy.authorize! :show?

    do_reader_download
  rescue StandardError => e
    Rails.logger.error "PdfEbooks#file raised #{e}"
    head :no_content
  end

  def do_reader_download
    pdf = UnpackService.root_path_from_noid(@pdf_ebook.noid, 'pdf_ebook') + ".pdf"
    if File.exist? pdf
      response.headers['Accept-Ranges'] = 'bytes'
      pdf.gsub!(/releases\/\d+/, "current")
      response.headers['X-Sendfile'] = pdf
      send_file pdf
    else
      head :no_content
    end
  end

  def download
    raise NotAuthorizedError unless @policy.download?
    redirect_to(hyrax.download_path(params[:id]))
  end

  def setup
    @pdf_ebook = Sighrax.from_noid(params[:id])
    @policy = PdfEbookPolicy.new(current_actor, @pdf_ebook)
  end
end
