# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Toolbox do
  subject { described_class.watermark(media, media_type, metadata) }

  let(:media) { 'media' }
  let(:media_type) { 'media_type' }
  let(:metadata) { {} }

  it { is_expected.to eq(media) }

  context 'application/pdf' do
    let(:media) { File.read(Rails.root.join(fixture_path, 'hello.pdf')) }
    let(:media_type) { 'application/pdf' }
    let(:metadata) { { title: 'title', press: 'press', request_origin: 'ip' } }
    let(:stamp) { double('stamp') }
    let(:pdf) { double('pdf') }
    let(:watermarked) { double('watermarked') }

    before do
      allow(CombinePDF).to receive(:create_page).and_return(stamp)
      allow(CombinePDF).to receive(:parse).with(media).and_return(pdf)
      allow(stamp).to receive(:textbox).with("#{metadata[:title]}", any_args) # rubocop:disable Style/UnneededInterpolation
      allow(stamp).to receive(:textbox).with("#{metadata[:press]}. All rights reserved.", any_args)
      allow(stamp).to receive(:textbox).with("Downloaded on behalf of #{metadata[:request_origin]}", any_args)
      allow(pdf).to receive(:stamp_pages).with(stamp)
      allow(pdf).to receive(:to_pdf).and_return(watermarked)
    end

    it do
      is_expected.to be watermarked
      expect(stamp).to have_received(:textbox).with("#{metadata[:title]}", any_args).ordered # rubocop:disable Style/UnneededInterpolation
      expect(stamp).to have_received(:textbox).with("#{metadata[:press]}. All rights reserved.", any_args).ordered
      expect(stamp).to have_received(:textbox).with("Downloaded on behalf of #{metadata[:request_origin]}", any_args).ordered
    end
  end
end
