# frozen_string_literal: true

require 'rails_helper'
require 'export'

describe Export::Exporter do
  describe '#new' do
    subject { described_class.new(monograph_id) }

    let(:monograph_id) { 'validnoid' }

    context 'monograph not found' do
      it { expect { subject }.to raise_error(ActiveFedora::ObjectNotFoundError) }
    end

    context 'monograph' do
      let(:monograph) { double('monograph') }

      before { allow(Monograph).to receive(:find).with(monograph_id).and_return(monograph) }

      it { is_expected.to be_an_instance_of(described_class) }
    end
  end

  describe '#export' do
    subject { described_class.new(monograph.id).export }

    let(:monograph) { build(:monograph, creator: ["First, Ms Joan\nSecond, Mr Tom"], contributor: ["Doe, Jane\nJoe, G.I."]) }
    let(:file1) { create(:file_set) }
    let(:file2) { create(:file_set) }
    let(:file3) { create(:file_set) }
    let(:expected) do
      <<~eos
        NOID,File Name,Link,Title,Resource Type,External Resource URL,Caption,Alternative Text,Copyright Holder,Copyright Status,Open Access?,Funder,Allow High-Res Display?,Allow Download?,Rights Granted,CC License,Permissions Expiration Date,After Expiration: Allow Display?,After Expiration: Allow Download?,Credit Line,Holding Contact,Exclusive to Fulcrum,Identifier(s),Content Type,Creator(s),Additional Creator(s),Creator Display,Sort Date,Display Date,Description,Publisher,Subject,ISBN(s),Buy Book URL,Pub Year,Pub Location,Series,Keywords,Section,Language,Transcript,Translation,DOI,Handle,Redirect to,Representative Kind
        instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder,instruction placeholder
        #{file1.id},,"=HYPERLINK(""#{Rails.application.routes.url_helpers.hyrax_file_set_url(file1)}"")",#{file1.title.first},#{file1.resource_type.first},,,,,,,,,,,,,,,,,,,,,,,#{file1.sort_date},,,,,,,,,,,,,,,,,,
        #{file2.id},,"=HYPERLINK(""#{Rails.application.routes.url_helpers.hyrax_file_set_url(file2)}"")",#{file2.title.first},#{file2.resource_type.first},,,,,,,,,,,,,,,,,,,,,,,#{file2.sort_date},,,,,,,,,,,,,,,,,,cover
        #{file3.id},,"=HYPERLINK(""#{Rails.application.routes.url_helpers.hyrax_file_set_url(file3)}"")",#{file3.title.first},#{file3.resource_type.first},,,,,,,,,,,,,,,,,,,,,,,#{file3.sort_date},,,,,,,,,,,,,,,,,,epub
        #{monograph.id},://:MONOGRAPH://:,"=HYPERLINK(""#{Rails.application.routes.url_helpers.hyrax_monograph_url(monograph)}"")",#{monograph.title.first},,,,,,,,,,,,,,,,,,,,,"First, Ms Joan; Second, Mr Tom","Doe, Jane; Joe, G.I.",,,,,,,,,,,,,://:MONOGRAPH://:,,,,,,,
      eos
    end

    before do
      monograph.ordered_members << file1
      monograph.ordered_members << file2
      monograph.ordered_members << file3
      monograph.representative_id = file2.id
      monograph.thumbnail_id = file2.id
      monograph.save!
      FeaturedRepresentative.create!(monograph_id: monograph.id, file_set_id: file3.id, kind: 'epub')
    end

    after { FeaturedRepresentative.destroy_all }

    it do
      actual = subject
      # puts actual
      expect(actual.empty?).to be false
      expect(actual).to match expected
    end
  end

  describe '#extract' do
    let(:monograph) { build(:monograph, creator: ["First, Ms Joan\nSecond, Mr Tom"], contributor: ["Doe, Jane\nJoe, G.I."]) }
    let(:file1) { create(:file_set) }
    let(:file2) { create(:file_set) }
    let(:file3) { create(:file_set) }
    let(:extract_path) { File.join('.', 'extract') }
    let(:press_path) { File.join(extract_path, monograph.press) }
    let(:monograph_path) { File.join(press_path, monograph.id) }
    let(:manifest_path) { File.join(monograph_path, "#{monograph.id}.csv") }
    let(:file1_path) { File.join(monograph_path, 'it.mp4') }
    let(:file2_original_path) { File.join(monograph_path, 'miranda.jpg') }
    let(:file2_revision_path) { File.join(monograph_path, 'shipwreck.jpg') }
    let(:file3_path) { File.join(monograph_path, 'fake_epub01.epub') }

    before do
      Hydra::Works::AddFileToFileSet.call(file1, File.open(File.join(fixture_path, 'it.mp4')), :original_file)
      file1.save!
      file1.reload
      Hydra::Works::AddFileToFileSet.call(file2, File.open(File.join(fixture_path, 'miranda.jpg')), :original_file)
      file2.save!
      file2.reload
      Hydra::Works::AddFileToFileSet.call(file3, File.open(File.join(fixture_path, 'fake_epub01.epub')), :original_file)
      file3.save!
      file3.reload
      monograph.ordered_members << file1
      monograph.ordered_members << file2
      monograph.ordered_members << file3
      monograph.representative_id = file2.id
      monograph.thumbnail_id = file2.id
      monograph.save!
      monograph.reload
      FeaturedRepresentative.create!(monograph_id: monograph.id, file_set_id: file3.id, kind: 'epub')
    end

    after do
      FeaturedRepresentative.destroy_all
    end

    it do
      Dir.chdir('tmp')
      FileUtils.rm_rf(File.join(".", "extract"))

      described_class.new(monograph.id).extract
      expect(Dir.exist?(extract_path)).to be true
      expect(Dir.exist?(press_path)).to be true
      expect(Dir.exist?(monograph_path)).to be true
      expect(File.exist?(manifest_path)).to be true
      expect(File.exist?(file1_path)).to be true
      expect(File.exist?(file2_original_path)).to be true
      expect(File.exist?(file3_path)).to be true

      FileUtils.cp(manifest_path, File.join('.', 'manifest.csv.1'))

      FileUtils.rm_rf(File.join(".", "extract"))
      Hydra::Works::AddFileToFileSet.call(file2, File.open(File.join(fixture_path, 'shipwreck.jpg')), :original_file)
      file2.save!
      file2.reload

      described_class.new(monograph.id).extract
      expect(Dir.exist?(extract_path)).to be true
      expect(Dir.exist?(press_path)).to be true
      expect(Dir.exist?(monograph_path)).to be true
      expect(File.exist?(manifest_path)).to be true
      expect(File.exist?(file1_path)).to be true
      expect(File.exist?(file2_revision_path)).to be true
      expect(File.exist?(file3_path)).to be true

      FileUtils.cp(manifest_path, File.join('.', 'manifest.csv.2'))

      # FileUtils.rm_rf(File.join(".", "extract"))
      Dir.chdir('..')
    end
  end
end
