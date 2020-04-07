# frozen_string_literal: true

FactoryBot.define do
  factory :model_tree do
    noid { Sighrax::Entity.null_entity.noid }
    entity { Sighrax::Entity.null_entity }
  end
end
