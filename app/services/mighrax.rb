# frozen_string_literal: true

require_dependency 'mighrax/identifier'
require_dependency 'mighrax/identifiers_uuid'
require_dependency 'mighrax/resource'
require_dependency 'mighrax/uuid'

module Mighrax
  class << self
    def factory(uuid)
      unpacked_uuid = begin
        if uuid.is_a?(String)
          uuid_unpack(uuid_pack(uuid))
        else
          uuid_unpack(uuid)
        end
      rescue StandardError => _e
        uuid_null_unpacked
      end
      return Resource.null_resource(uuid) if /^00000000-0000-0000-0000-000000000000$/.match?(unpacked_uuid)
      Resource.send(:new, uuid)
    end

    def uuid_null_packed
      Array.new(16, 0).pack('C*').force_encoding('ascii-8bit')
    end

    def uuid_null_unpacked
      '00000000-0000-0000-0000-000000000000'
    end

    def uuid_generator_packed
      uuid_pack(open('http://www.famkruithof.net/uuid/uuidgen').read.scan(/([-[:alnum:]]+)\<\/h3\>/)[0][0])
    end

    def uuid_generator_unpacked
      uuid_unpack(uuid_generator_packed)
    end

    def uuid_pack(unpacked)
      text = unpacked.dup
      text.delete!('-')
      return uuid_null_packed unless text.length == 32

      bytes = []
      16.times do |i|
        n = 2 * i
        bytes.push(('0x' + text[n] + text[n + 1]).to_i(16))
      end
      bytes.pack('C*').force_encoding('ascii-8bit')
    rescue StandardError => _e
      uuid_null_packed
    end

    def uuid_unpack(packed)
      return uuid_null_unpacked unless packed.length == 16

      unpacked = []
      16.times do |i|
        byte = packed[i].bytes[0].to_s(16)
        unpacked.push(byte.length == 1 ? '0' + byte : byte)
      end
      unpacked = unpacked.join
      unpacked.insert(8, '-')
      unpacked.insert(13, '-')
      unpacked.insert(18, '-')
      unpacked.insert(23, '-')
      unpacked
    rescue StandardError => _e
      uuid_null_unpacked
    end
  end
end
