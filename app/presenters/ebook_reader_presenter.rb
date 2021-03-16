# frozen_string_literal: true

class EbookReaderPresenter < ApplicationPresenter
  include ActionView::Helpers::UrlHelper
  attr_reader :monograph, :current_ability, :current_actor, :ebook_presenters

  def initialize(monograph_presenter, current_ability, current_actor)
    @monograph = monograph_presenter
    @current_ability = current_ability
    @current_actor = current_actor
    @ebook_presenters = Hyrax::PresenterFactory.build_for(ids: [@monograph.epub_id, @monograph.mobi_id, @monograph.pdf_ebook_id], presenter_class: Hyrax::FileSetPresenter, presenter_args: @current_ability).compact
    @ebook_presenters.each do |ebook|
      ebook_format = if ebook.epub?
                       "EPUB"
                     elsif ebook.mobi?
                       "MOBI"
                     elsif ebook.pdf_ebook?
                       "PDF"
                     end
      ebook.class_eval { attr_accessor "ebook_format" }
      ebook.instance_variable_set(:@ebook_format, ebook_format)
    end
  end

  def epub
    @ebook_presenters.map { |ebook| ebook if ebook.epub? }.compact.first
  end

  def mobi
    @ebook_presenters.map { |ebook| ebook if ebook.mobi? }.compact.first
  end

  def pdf_ebook
    @ebook_presenters.map { |ebook| ebook if ebook.pdf_ebook? }.compact.first
  end

  def readerable?(ebook_presenter)
    Rails.logger.debug("[EBOOK READER] ebook_presenter.blank? #{ebook_presenter.blank?} (#{ebook_presenter.class})")
    return false if ebook_presenter.blank?
    EbookPolicy.new(current_actor, Sighrax.from_presenter(ebook_presenter)).reader?
  end

  def readerable_ebooks?
    @ebook_presenters.each do |ebook|
      return true if readerable?(ebook)
    end
    false
  end
end
