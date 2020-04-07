# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ModelTreeData, type: :model do
  context 'Factory Bot' do
    subject(:data) { create(:model_tree_data) }

    it do
      expect(data).to be_an_instance_of(Hash)
    end
  end
end
