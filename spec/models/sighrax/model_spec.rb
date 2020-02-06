# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sighrax::Model, type: :model do
  subject { described_class.send(:new, noid, data) }

  let(:noid) { 'validnoid' }
  let(:data) { {} }

  it { is_expected.to be_an_instance_of(described_class) }
  it { is_expected.to be_a_kind_of(Sighrax::Entity) }
  it { expect(subject.resource_type).to eq :Model }
  it { expect(subject.send(:model_type)).to be_nil }

  describe '#model_type' do
    let(:data) { { 'has_model_ssim' => ['Model'] } }

    it { expect(subject.send(:model_type)).to eq 'Model' }
  end

  describe '#title' do
    let(:data) { { 'title_tesim' => ['Title'] } }

    it { expect(subject.title).to eq 'Title' }
  end

  describe '#created' do
    let(:data) { { 'date_uploaded_dtsi' => ['Created'] } }

    it { expect(subject.created).to eq 'Created' }
  end

  describe '#modified' do
    let(:data) { { 'date_modified_dtsi' => ['Modified'] } }

    it { expect(subject.modified).to eq 'Modified' }
  end
end
