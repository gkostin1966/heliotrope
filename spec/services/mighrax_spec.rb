# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mighrax do
  describe '#facotry' do
    subject { described_class.factory(uuid) }

    context 'NullResource' do
      context 'nil' do
        let(:uuid) { nil }

        it do
          is_expected.to be_an_instance_of(Mighrax::NullResource)
          expect(subject.uuid).to be uuid
        end
      end

      context 'null' do
        let(:uuid) { '00000000-0000-0000-0000-000000000000' }

        it do
          is_expected.to be_an_instance_of(Mighrax::NullResource)
          expect(subject.uuid).to be uuid
        end
      end

      context 'invalid uuid' do
        let(:uuid) { '00000000-0000-0000-0000-00000000000X' }

        it do
          is_expected.to be_an_instance_of(Mighrax::NullResource)
          expect(subject.uuid).to be uuid
        end
      end
    end

    context 'Resource' do
      let(:uuid) { '00000000-0000-0000-0000-00000000000f' }

      it do
        is_expected.to be_an_instance_of(Mighrax::Resource)
        expect(subject.uuid).to be uuid
      end
    end
  end

  describe '#uuid_null_packed' do
    subject { described_class.uuid_null_packed }

    it { is_expected.to eq(Array.new(16, 0).pack('C*').force_encoding('ascii-8bit')) }
  end

  describe '#uuid_null_unpacked' do
    subject { described_class.uuid_null_unpacked }

    it { is_expected.to eq('00000000-0000-0000-0000-000000000000') }
  end

  describe '#uuid_pack' do
    subject { described_class.uuid_pack(unpacked) }

    let(:unpacked) { described_class.uuid_null_unpacked }

    it { is_expected.to eq(described_class.uuid_null_packed) }

    context '0x0F' do
      let(:unpacked) { '0f0f0f0f-0f0f-0f0f-0f0f-0f0f0f0f0f0f' }

      it { is_expected.to eq(Array.new(16, 15).pack('C*').force_encoding('ascii-8bit')) }
    end

    context '0xFF' do
      let(:unpacked) { 'ffffffff-ffff-ffff-ffff-ffffffffffff' }

      it { is_expected.to eq(Array.new(16, 255).pack('C*').force_encoding('ascii-8bit')) }
    end
  end

  describe '#uuid_unpack' do
    subject { described_class.uuid_unpack(packed) }

    let(:packed) { described_class.uuid_null_packed }

    it { is_expected.to eq(described_class.uuid_null_unpacked) }

    context '\x0F' do
      let(:packed) { Array.new(16, 15).pack('C*').force_encoding('ascii-8bit') }

      it { is_expected.to eq('0f0f0f0f-0f0f-0f0f-0f0f-0f0f0f0f0f0f') }
    end

    context '\xFF' do
      let(:packed) { Array.new(16, 255).pack('C*').force_encoding('ascii-8bit') }

      it { is_expected.to eq('ffffffff-ffff-ffff-ffff-ffffffffffff') }
    end
  end
end
