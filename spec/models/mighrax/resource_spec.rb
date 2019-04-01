# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mighrax::Resource, type: :model do
  context 'null resource' do
    subject { described_class.null_resource }

    it { is_expected.to be_an_instance_of(Mighrax::NullResource) }
    it { expect(subject.uuid).to eq '00000000-0000-0000-0000-000000000000' }
    it { expect(subject.valid?).to be false }
    it { expect(subject.resource_type).to eq :NullResource }
    it { expect(subject.resource_id).to eq '00000000-0000-0000-0000-000000000000' }
    it { expect(subject.resource_token).to eq "#{subject.resource_type}:#{subject.resource_id}" }
  end

  context 'resource' do
    subject(:resource) { described_class.send(:new, uuid) }

    let(:uuid) { 'valid_uuid' }

    it { is_expected.to be_an_instance_of(described_class) }
    it { expect(subject.uuid).to eq uuid }
    it { expect(subject.valid?).to be true }
    it { expect(subject.resource_type).to eq :Resource }
    it { expect(subject.resource_id).to eq uuid }
    it { expect(subject.resource_token).to eq "#{subject.resource_type}:#{subject.resource_id}" }
  end
end
