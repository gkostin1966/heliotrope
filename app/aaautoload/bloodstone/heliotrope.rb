# frozen_string_literal: true

module Bloodstone
  module Heliotrope
    class << self
      def show_monograph_catalog_nag_banner?(actor, monograph)
        monograph.present? && show_press_catalog_nag_banner?(actor)
      end

      def show_press_catalog_nag_banner?(actor)
        nag_product = current_year_nag_product
        return false if product_blank?(nag_product)
        !Greensub.actor_products(actor).include?(nag_product)
      end

      def current_year_nag_product
        Product.find_by(identifier: current_year_nag_product_identifier)
      end

      def current_year_nag_product_identifier
        'nag_' + Time.current.year.to_s
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
