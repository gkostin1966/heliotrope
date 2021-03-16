# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EbookPolicy do
  describe '#download?' do
    subject { policy.download? }

    let(:policy) { described_class.new(actor, ebook) }
    let(:actor) { Anonymous.new({}) }
    let(:ebook) { instance_double(Sighrax::Ebook, 'ebook') }
    let(:download_op) { instance_double(EbookDownloadOperation, 'download_op', allowed?: allowed) }
    let(:allowed) { false }

    before { allow(EbookDownloadOperation).to receive(:new).with(actor, ebook).and_return download_op }

    it { is_expected.to be false }

    context 'when allowed' do
      let(:allowed) { true }

      it { is_expected.to be true }
    end
  end

  describe '#reader?' do
    subject { policy.reader? }

    let(:policy) { described_class.new(actor, ebook) }
    let(:actor) { Anonymous.new({}) }
    let(:ebook) { instance_double(Sighrax::Ebook, 'ebook') }
    let(:reader_op) { instance_double(EbookReaderOperation, 'reader_op', allowed?: allowed) }
    let(:allowed) { false }

    before { allow(EbookReaderOperation).to receive(:new).with(actor, ebook).and_return reader_op }

    it { is_expected.to be false }

    context 'when allowed' do
      let(:allowed) { true }

      it { is_expected.to be false }

      context 'when developer' do
        before { allow(actor).to receive(:developer?).and_return true }

        it { is_expected.to be true }
      end
    end
  end

  describe '#watermark?' do
    subject { policy.watermark? }

    let(:policy) { described_class.new(actor, ebook) }
    let(:actor) { Anonymous.new({}) }
    let(:ebook) { instance_double(Sighrax::Ebook, 'ebook', watermarkable?: watermarkable, publisher: publisher) }
    let(:watermarkable) { false }
    let(:publisher) { instance_double(Sighrax::Publisher, 'publisher', watermark?: watermark) }
    let(:watermark) { false }

    it { is_expected.to be false }

    context 'when watermarkable?' do
      let(:watermarkable) { true }

      it { is_expected.to be false }

      context 'when publisher watermark' do
        let(:watermark) { true }

        it { is_expected.to be true }
      end
    end
  end
end
