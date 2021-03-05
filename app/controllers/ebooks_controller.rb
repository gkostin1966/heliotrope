# frozen_string_literal: true

class EbooksController < CheckpointController
  before_action :setup

  def reader
    raise NotAuthorizedError unless @policy.reader?
    case @ebook
    when Sighrax::EpubEbook
      return redirect_to(epub_ebook_path(params[:id]))
    when Sighrax::PdfEbook
      return redirect_to(pdf_ebook_path(params[:id]))
    end
    raise NotAuthorizedError
  end

  def download
    raise NotAuthorizedError unless @policy.download?
    case @ebook
    when Sighrax::EpubEbook
      return redirect_to(download_epub_ebook_path(params[:id]))
    when Sighrax::PdfEbook
      return redirect_to(download_pdf_ebook_path(params[:id]))
    end
    raise NotAuthorizedError
  end

  private

    def setup
      @ebook = Sighrax.from_noid(params[:id])
      @policy = EbookPolicy.new(current_actor, @ebook)
    end
end
