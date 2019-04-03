# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mighrax::Identifier, type: :model do
  subject { create(:identifier) }

  it do
    is_expected.to be_valid
    expect(subject.resource_type).to eq :Identifier
    expect(subject.resource_id).to eq subject.id
    expect(subject.uuid).to be nil
    expect(subject.update?).to be true
    expect(subject.destroy?).to be true
    expect(Mighrax::Identifier.count).to eq(1)
    expect(Mighrax::IdentifiersUuid.count).to be_zero
    expect(Mighrax::Uuid.count).to be_zero

    uuid = create(:uuid)
    expect(Mighrax::Uuid.count).to eq(1)

    subject.uuid = uuid
    subject.save!
    subject.reload
    expect(subject.uuid).to eq(uuid)
    expect(subject.update?).to be true
    expect(subject.destroy?).to be false
    expect { subject.destroy }.not_to raise_exception(ActiveRecord::StatementInvalid)
    expect(Mighrax::Identifier.count).to eq(1)
    expect(Mighrax::IdentifiersUuid.count).to eq(1)
    expect(Mighrax::Uuid.count).to eq(1)

    uuid2 = create(:uuid)
    expect(Mighrax::Uuid.count).to eq(2)

    expect { subject.uuid = uuid2 }.not_to raise_exception(NoMethodError)

    uuid.identifiers.destroy(subject)
    subject.reload
    expect(subject.uuid).to be nil
    expect(subject.update?).to be true
    expect(subject.destroy?).to be true
    expect(Mighrax::Identifier.count).to eq(1)
    expect(Mighrax::IdentifiersUuid.count).to be_zero
    expect(Mighrax::Uuid.count).to eq(2)

    subject.uuid = uuid2
    subject.save!
    subject.reload
    expect(subject.uuid).to eq(uuid2)
    expect(subject.update?).to be true
    expect(subject.destroy?).to be false
    expect { subject.destroy }.not_to raise_exception(ActiveRecord::StatementInvalid)
    expect(Mighrax::Identifier.count).to eq(1)
    expect(Mighrax::IdentifiersUuid.count).to eq(1)
    expect(Mighrax::Uuid.count).to eq(2)

    uuid.destroy
    expect(Mighrax::Identifier.count).to eq(1)
    expect(Mighrax::IdentifiersUuid.count).to eq(1)
    expect(Mighrax::Uuid.count).to eq(1)

    uuid2.identifiers.destroy(subject)
    subject.reload
    expect(subject.uuid).to be nil
    expect(subject.update?).to be true
    expect(subject.destroy?).to be true
    expect(Mighrax::Identifier.count).to eq(1)
    expect(Mighrax::IdentifiersUuid.count).to be_zero
    expect(Mighrax::Uuid.count).to eq(1)

    subject.destroy
    expect(Mighrax::Identifier.count).to be_zero
    expect(Mighrax::IdentifiersUuid.count).to be_zero
    expect(Mighrax::Uuid.count).to eq(1)

    uuid2.destroy
    expect(Mighrax::Identifier.count).to be_zero
    expect(Mighrax::IdentifiersUuid.count).to be_zero
    expect(Mighrax::Uuid.count).to be_zero
  end
end
