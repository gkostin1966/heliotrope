# frozen_string_literal: true

module Mighrax
  class IdentifiersUuid < ApplicationRecord
    belongs_to :identifier
    belongs_to :uuid
  end
end
