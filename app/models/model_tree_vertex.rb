# frozen_string_literal: true

class ModelTreeVertex < ApplicationRecord
  validates :noid, presence: true, format: { with: /\A[[:alnum:]]{9}\z/, message: 'must be 9 alphanumeric characters' }, uniqueness: true
  validates :data, presence: true # , format: { with: /\A{.*}z/, message: 'must be a JSON object' }
end
