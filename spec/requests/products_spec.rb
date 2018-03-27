# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Products", type: :request do
  let(:product) { create(:product) }

  context 'unauthorized' do
    describe "GET /products" do
      it do
        get products_path
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(presses_path)
      end
    end
    describe "GET /products/1/purchase" do
      it do
        get purchase_product_path(product)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(product.purchase)
      end
    end
    describe "GET /products/1/help" do
      it do
        get help_product_path(product)
        expect(response).to have_http_status(200)
      end
    end
  end

  context 'authorized' do
    let(:user) { create(:platform_admin) }

    before { cosign_sign_in(user) }

    describe "GET /products" do
      it do
        get products_path
        expect(response).to have_http_status(200)
      end
    end
    describe "GET /products/1/purchase" do
      it do
        get purchase_product_path(product)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(product.purchase)
      end
    end
    describe "GET /products/1/help" do
      it do
        get help_product_path(product)
        expect(response).to have_http_status(200)
      end
    end
  end
end