# frozen_string_literal: true

module Sighrax
  # Deprecated
  class PortableDocumentFormat < PdfEbook
    private_class_method :new

    private

      def initialize(noid, data, reload = true)
        super(noid, data, reload)
      end
  end
end
