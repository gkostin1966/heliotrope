# frozen_string_literal: true

class EbookPolicy < ApplicationPolicy
  def initialize(actor, target)
    super(actor, target)
  end

  def download?
    EbookDownloadOperation.new(actor, target).allowed?
  end

  def reader?
    EbookReaderOperation.new(actor, target).allowed? && actor.developer?
  end

  def watermark?
    return false unless target.watermarkable?

    target.publisher.watermark?
  end
end
