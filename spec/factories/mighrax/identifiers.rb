# frozen_string_literal: true

FactoryBot.define do
  factory :identifier, class: Mighrax::Identifier do
    sequence(:name) { |n| "IdentifierName#{n}" }
  end
end
