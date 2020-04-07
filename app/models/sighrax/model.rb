# frozen_string_literal: true

module Sighrax
  class Model < Entity
    private_class_method :new

    def title
      Array(data['title_tesim']).first || super
    end

    def representative?
      principal_noid.present?
    end

    def principal
      Sighrax.from_noid(principal_noid)
    end

    def principal_noid
      Array(data['parent_model_noid_ssim']).first
    end

    protected

      def model_type
        Array(data['has_model_ssim']).first
      end

    private

      def initialize(noid, data)
        super(noid, data)
      end
  end
end
