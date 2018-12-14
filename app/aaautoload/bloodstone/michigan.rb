# frozen_string_literal: true

module Bloodstone
  module Michigan
    class << self
      def show_monograph_catalog_ebc_banner?(actor, monograph)
        monograph.present? && show_press_catalog_ebc_banner?(actor)
      end

      def show_press_catalog_ebc_banner?(actor)
        ebc_product = current_year_ebc_product
        return false if product_blank?(ebc_product)
        !Greensub.actor_products(actor).include?(ebc_product)
      end

      def current_year_ebc_product
        Product.find_by(identifier: current_year_ebc_product_identifier)
      end

      def current_year_ebc_product_identifier
        'ebc_' + Time.current.year.to_s
      end

      private

        def product_blank?(product)
          !product_present?(product)
        end

        def product_present?(product)
          product.present? && product.name.present? && product.purchase.present?
        end
    end
  end
end
