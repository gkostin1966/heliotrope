# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EpubEbookPolicy do
  describe '#show?' do
    subject { policy.show? }

    let(:policy) { described_class.new(actor, epub_ebook, share) }
    let(:actor) { Anonymous.new({}) }
    let(:epub_ebook) { instance_double(Sighrax::EpubEbook, 'epub_ebook') }
    let(:share) { false }
    let(:reader_op) { instance_double(EbookReaderOperation, 'reader_op', allowed?: allowed) }
    let(:allowed) { false }

    before { allow(EbookReaderOperation).to receive(:new).with(actor, epub_ebook).and_return reader_op }

    it { is_expected.to be false }

    context 'when share' do
      let(:share) { true }

      it { is_expected.to be true }
    end

    context 'when allowed' do
      let(:allowed) { true }

      it { is_expected.to be true }
    end
  end
end
