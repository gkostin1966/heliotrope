# frozen_string_literal: true

module Sighrax
  # Deprecated
  class ElectronicPublication < EpubEbook
    private_class_method :new

    private

      def initialize(noid, data)
        super(noid, data)
      end
  end
end
