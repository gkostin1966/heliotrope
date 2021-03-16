# frozen_string_literal: true

class EbookIntervalPresenter < ApplicationPresenter
  def initialize(args)
    @args = args
  end

  def title
    @args[:title]
  end

  def level
    @args[:level]
  end

  def cfi
    @args[:cfi]
  end

  def downloadable?
    @args[:downloadable?]
  end
end
