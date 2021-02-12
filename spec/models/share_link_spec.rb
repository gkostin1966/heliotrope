# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShareLink, type: :model do
  subject { described_class.new(json_web_token) }

  let(:json_web_token) { {} }

  it { is_expected.not_to be nil }
end
