# frozen_string_literal: true

class ModelTreeData
  include ActiveModel::Model
  private_class_method :new

  attr_reader :data

  def self.from_noid(noid)
    from_json(ModelTreeVertex.find_by(noid: noid)&.data || {}.to_json)
  end

  def self.from_json(json)
    from_hash(JSON.parse(json))
  end

  def self.from_hash(hash)
    new(hash)
  end

  def ==(other)
    data == other.data
  end

  private

    def initialize(data = {})
      @data = data
    end
end
