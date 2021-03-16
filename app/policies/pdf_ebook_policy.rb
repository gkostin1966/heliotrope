# frozen_string_literal: true

class PdfEbookPolicy < ApplicationPolicy
  def initialize(actor, target, share = false)
    super(actor, target)
    @share = share
  end

  def show?
    @share || EbookReaderOperation.new(actor, target).allowed?
  end

  def download?
    EbookDownloadOperation.new(actor, target).allowed?
  end
end
