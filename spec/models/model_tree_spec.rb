# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ModelTree, type: :model do
  context 'Factory Bot' do
    subject(:tree) { create(:model_tree) }

    it do
      expect(tree).to be_an_instance_of(ModelTree)
    end
  end
end
