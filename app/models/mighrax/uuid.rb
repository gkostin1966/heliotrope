# frozen_string_literal: true

module Mighrax
  class Uuid < ApplicationRecord
    include Filterable

    scope :unpacked_like, ->(like) { where("unpacked like ?", "%#{like}%") }

    has_many :identifiers_uuids, dependent: :destroy
    has_many :identifiers, through: :identifiers_uuids

    validates :packed, presence: true, allow_blank: false, uniqueness: true
    validates :unpacked, presence: true, allow_blank: false, uniqueness: true

    def self.null
      Uuid.find_or_create_by(packed: Mighrax.uuid_null_packed, unpacked: Mighrax.uuid_null_unpacked)
    end

    def self.generator
      packed = Mighrax.uuid_generator_packed
      unpacked = Mighrax.uuid_unpack(packed)
      Uuid.create!(packed: packed, unpacked: unpacked)
    end

    def update?
      false
    end

    def destroy?
      identifiers.blank?
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
