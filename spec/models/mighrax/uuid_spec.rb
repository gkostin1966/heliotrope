# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mighrax::Uuid, type: :model do
  subject { create(:uuid) }

  it do
    is_expected.to be_valid
    expect(subject.resource_type).to eq :Uuid
    expect(subject.resource_id).to eq subject.id
    expect(subject.identifiers).to be_empty
    expect(subject.update?).to be false
    expect(subject.destroy?).to be true
    expect(Mighrax::Identifier.count).to be_zero
    expect(Mighrax::IdentifiersUuid.count).to be_zero
    expect(Mighrax::Uuid.count).to eq(1)

    n = 3
    identifiers = []
    n.times { identifiers << create(:identifier) }
    expect(Mighrax::Identifier.count).to eq(n)

    identifiers.each_with_index do |identifier, index|
      expect(subject.identifiers.count).to eq(index)
      subject.identifiers << identifier
      subject.save!
      expect(subject.update?).to be false
      expect(subject.destroy?).to be false
      expect(Mighrax::IdentifiersUuid.count).to eq(index + 1)
    end

    identifiers.each_with_index do |identifier, index|
      expect(subject.update?).to be false
      expect(subject.destroy?).to be false
      expect(subject.identifiers.count).to eq(n - index)
      subject.identifiers.delete(identifier)
      subject.save!
      expect(Mighrax::IdentifiersUuid.count).to eq(n - (index + 1))
    end

    expect(subject.update?).to be false
    expect(subject.destroy?).to be true
    expect(Mighrax::Identifier.count).to eq(n)
    expect(Mighrax::IdentifiersUuid.count).to be_zero
    expect(Mighrax::Uuid.count).to eq(1)

    identifiers.each(&:destroy)
    subject.destroy
    expect(Mighrax::Identifier.count).to be_zero
    expect(Mighrax::Uuid.count).to be_zero
  end
end
