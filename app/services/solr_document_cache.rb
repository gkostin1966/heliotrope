# frozen_string_literal: true

class SolrDocumentCache
  def initialize(time_to_live_in_minutes = 5)
    @cache = Concurrent::Hash.new { |hash, key| hash[key] = { solr_document: nil, timestamp: Time.now.utc } }
    @time_to_live = time_to_live_in_minutes
  end

  def clear
    @cache.clear
  end

  def prune
    @cache.delete_if { |_key, entry| entry[:timestamp] < @time_to_live.minutes.ago }
  end

  def read(noid, reload = false) # rubocop:disable Metrics/CyclomaticComplexity
    noid = noid&.to_s&.downcase
    return nil unless ValidationService.valid_noid?(noid)

    entry = @cache[noid]
    return entry[:solr_document] if entry[:solr_document].present? && (entry[:timestamp] > @time_to_live.minutes.ago) && !reload

    prune if entry[:timestamp] < @time_to_live.minutes.ago
    solr_document = begin
                      ActiveFedora::SolrService.query("{!terms f=id}#{noid}", rows: 1).first
                    rescue StandardError => _e
                      entry[:solr_document]
                    end
    write(noid, solr_document)
  end

  def write(noid, solr_document)
    noid = noid&.to_s&.downcase
    return nil unless ValidationService.valid_noid?(noid)

    @cache[noid] = { solr_document: solr_document, timestamp: Time.now.utc }
    solr_document
  end

  def delete(noid)
    noid = noid&.to_s&.downcase
    return nil unless ValidationService.valid_noid?(noid)

    entry = @cache.delete(noid)
    return nil if entry.blank?

    entry[:solr_document]
  end
end
