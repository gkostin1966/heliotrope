# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Reacts", type: :request do
  describe "GET /reacts" do
    it do
      get index_react_path
      expect(response).to have_http_status(:success)
    end
  end
end
