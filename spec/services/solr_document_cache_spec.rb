# frozen_string_literal: true

require 'rails_helper'

describe SolrDocumentCache do
  let(:cache) { described_class.new(ttl) }
  let(:ttl) { 1 }
  let(:noid) { 'validnoid' }
  let(:solr_document) { instance_double(SolrDocument, 'solr_document') }

  describe '#clear' do
    it 'clears the cache' do
      cache.write(noid, solr_document)
      cache.clear
      expect(cache.read(noid)).to eq(nil)
    end
  end

  describe '#prune' do
    context 'entry has time to live' do
      let(:ttl) { 1 }

      it 'leaves cache entry' do
        cache.write(noid, solr_document)
        cache.prune
        expect(cache.read(noid)).to be(solr_document)
      end
    end

    context 'entry time to live expired' do
      let(:ttl) { 0 }

      it 'deletes cache entry' do
        cache.write(noid, solr_document)
        cache.prune
        expect(cache.read(noid)).to be(nil)
      end
    end
  end

  describe "#read" do
    it 'reads cache entry' do
      expect(cache.read(noid)).to be(nil)
      cache.write(noid, solr_document)
      expect(cache.read(noid)).to be(solr_document)
    end

    context 'lazy reload' do
      before do
        allow(ActiveFedora::SolrService).to receive(:query).with("{!terms f=id}#{noid}", rows: 1).and_return([solr_document])
      end

      it 'writes and reads cache entry' do
        expect(cache.read(noid)).to be(solr_document)
      end
    end

    context 'force reload' do
      let(:new_solr_document) { instance_double(SolrDocument, 'new_solr_document') }

      before do
        allow(ActiveFedora::SolrService).to receive(:query).with("{!terms f=id}#{noid}", rows: 1).and_return([new_solr_document])
      end

      it 'writes and reads cache entry' do
        cache.write(noid, solr_document)
        expect(cache.read(noid, true)).to be(new_solr_document)
      end
    end
  end

  describe "#write" do
    it 'writes cache entry' do
      expect(cache.read(noid)).to be(nil)
      cache.write(noid, solr_document)
      expect(cache.read(noid)).to be(solr_document)
    end
  end

  describe "#delete" do
    it 'deletes cache entry' do
      cache.write(noid, solr_document)
      cache.delete(noid)
      expect(cache.read(noid)).to be(nil)
    end
  end
end
