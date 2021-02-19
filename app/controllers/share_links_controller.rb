# frozen_string_literal: true

class ShareLinksController < CheckpointController
  def show
    _id = params[:id] # JSON Web Token
    _monograph_id = params[:monograph_id]
    # redirect_to monograph's epub or pdf_ebook
  end

  def new
    _monograph_id = params[:monograph_id]
    # return JSON Web Token
  end

  def show_monograph
  end

  def show_epub
  end

  def show_pdf_ebook
  end
end
