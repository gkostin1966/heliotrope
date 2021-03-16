# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EbookReaderPresenter do
  subject { described_class.new(monograph, current_ability, current_actor) }

  let(:user) { create(:user) }
  let(:current_ability) { Ability.new(user) }
  let(:current_actor) { user }

  let(:monograph) { Hyrax::MonographPresenter.new(SolrDocument.new(id: 'monograph_id', visibility_ssi: 'open', has_model_ssim: ['Monograph']), current_ability) }
  let(:epub_ebook_doc) { SolrDocument.new(id: '111111111', visibility_ssi: 'open', monograph_id_ssim: 'monograph_id', has_model_ssim: ['FileSet'], file_size_lts: 20_000, allow_reader_ssim: 'yes') }
  let(:mobi_ebook_doc) { SolrDocument.new(id: '222222222', visibility_ssi: 'open', monograph_id_ssim: 'monograph_id', has_model_ssim: ['FileSet'], file_size_lts: 30_000, allow_reader_ssim: 'yes') }
  let(:pdf_ebook_doc) { SolrDocument.new(id: '333333333', visibility_ssi: 'open', monograph_id_ssim: 'monograph_id', has_model_ssim: ['FileSet'], file_size_lts: 40_000, allow_reader_ssim: 'yes') }

  before do
    create(:featured_representative, file_set_id: '111111111', work_id: 'monograph_id', kind: 'epub')
    create(:featured_representative, file_set_id: '222222222', work_id: 'monograph_id', kind: 'mobi')
    create(:featured_representative, file_set_id: '333333333', work_id: 'monograph_id', kind: 'pdf_ebook')
    ActiveFedora::SolrService.add([epub_ebook_doc.to_h, mobi_ebook_doc.to_h, pdf_ebook_doc.to_h])
    ActiveFedora::SolrService.commit
    # nothing in this spec tests Checkpointy stuff and to show the "allow_reader_ssim" checks haven't prevented...
    # even reaching Checkpointy checks in EntityPolicy we need to make sure EntityPolicy.reader? doesn't return...
    # false at the end due to lack of Product access
    allow(Sighrax).to receive(:access?).with(current_actor, anything).and_return(true)
  end

  context "formats" do
    it "has the right ebook format" do
      expect(subject.epub_ebook.ebook_format).to eq "EPUB_EBOOK"
      expect(subject.mobi_ebook.ebook_format).to eq "MOBI_EBOOK"
      expect(subject.pdf_ebook.ebook_format).to eq "PDF"
    end
  end

  context "file sizes" do
    it "has file sizes" do
      expect(subject.epub_ebook.file_size).to eq 20_000
      expect(subject.mobi_ebook.file_size).to eq 30_000
      expect(subject.pdf_ebook.file_size).to eq 40_000
    end
  end

  describe "#readerable_ebooks?" do
    context "with readerable ebooks" do
      it "returns true" do
        expect(subject.readerable_ebooks?).to be true
      end
    end

    context "with a readerable ebook" do
      let(:epub_ebook_doc) { SolrDocument.new(id: '111111111', visibility_ssi: 'restricted', monograph_id_ssim: 'monograph_id', has_model_ssim: ['FileSet'], file_size_lts: 20_000, allow_reader_ssim: 'no') }
      let(:mobi_ebook_doc) { SolrDocument.new(id: '222222222', visibility_ssi: 'restricted', monograph_id_ssim: 'monograph_id', has_model_ssim: ['FileSet'], file_size_lts: 30_000, allow_reader_ssim: 'no') }
      let(:pdf_ebook_doc) { SolrDocument.new(id: '333333333', visibility_ssi: 'open', monograph_id_ssim: 'monograph_id', has_model_ssim: ['FileSet'], file_size_lts: 40_000, allow_reader_ssim: 'yes') }

      before do
        ActiveFedora::SolrService.add([epub_ebook_doc.to_h, mobi_ebook_doc.to_h, pdf_ebook_doc.to_h])
        ActiveFedora::SolrService.commit
      end

      it "returns true" do
        expect(subject.readerable_ebooks?).to be true
      end
    end

    context "with no readerable ebooks" do
      let(:epub_ebook_doc) { SolrDocument.new(id: '111111111', visibility_ssi: 'restricted', monograph_id_ssim: 'monograph_id', has_model_ssim: ['FileSet'], file_size_lts: 20_000, allow_reader_ssim: 'no') }
      let(:mobi_ebook_doc) { SolrDocument.new(id: '222222222', visibility_ssi: 'restricted', monograph_id_ssim: 'monograph_id', has_model_ssim: ['FileSet'], file_size_lts: 30_000, allow_reader_ssim: 'no') }
      let(:pdf_ebook_doc) { SolrDocument.new(id: '333333333', visibility_ssi: 'open', monograph_id_ssim: 'monograph_id', has_model_ssim: ['FileSet'], file_size_lts: 40_000, allow_reader_ssim: 'no') }

      before do
        ActiveFedora::SolrService.add([epub_ebook_doc.to_h, mobi_ebook_doc.to_h, pdf_ebook_doc.to_h])
        ActiveFedora::SolrService.commit
      end

      it "returns false" do
        expect(subject.readerable_ebooks?).to be false
      end
    end
  end

  describe "#readerable?" do
    it "is readerable" do
      expect(subject.readerable?(subject.epub_ebook)).to be true
      expect(subject.readerable?(subject.mobi_ebook)).to be true
      expect(subject.readerable?(subject.pdf_ebook)).to be true
    end
  end

  it "has csb_reader_links" do
    allow(current_ability).to receive(:platform_admin?).and_return(false)
    allow(current_ability).to receive(:can?).and_return(false)

    expect(subject.csb_reader_links).to eq [{ format: "EPUB", size: "19.5 KB", href: "/epub_ebooks/111111111" },
                                            { format: "MOBI", size: "29.3 KB", href: "/mobi_ebooks/222222222" },
                                            { format: "PDF",  size: "39.1 KB", href: "/pdf_ebooks/333333333" }]
  end
end
