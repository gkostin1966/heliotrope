# frozen_string_literal: true

module Mighrax
  class Identifier < ApplicationRecord
    include Filterable

    scope :name_like, ->(like) { where("name like ?", "%#{like}%") }

    has_one :identifiers_uuid # rubocop:disable Rails/HasManyOrHasOneDependent
    has_one :uuid, through: :identifiers_uuid

    validates :name, presence: true, allow_blank: false, uniqueness: true

    def aliases
      Identifier.find(IdentifiersUuid.where.not(identifier_id: id).where(uuid: uuid).map(&:identifier_id))
    end

    def update?
      true
    end

    def destroy?
      uuid.blank?
    end

    def resource_type
      type
    end

    def resource_id
      id
    end

    def resource_token
      @resource_token ||= resource_type.to_s + ':' + resource_id.to_s
    end

    protected

      def type
        @type ||= /^Mighrax::(.+$)/.match(self.class.to_s)[1].to_sym
      end
  end
end
