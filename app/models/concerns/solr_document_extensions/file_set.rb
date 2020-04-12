# frozen_string_literal: true

module SolrDocumentExtensions
  module FileSet
    extend ActiveSupport::Concern

    def allow_display_after_expiration
      Array(self[Solrizer.solr_name('allow_display_after_expiration', :symbol)]).first
    end

    def allow_download
      Array(self[Solrizer.solr_name('allow_download', :symbol)]).first
    end

    def allow_download_after_expiration
      Array(self[Solrizer.solr_name('allow_download_after_expiration', :symbol)]).first
    end

    def allow_hi_res
      Array(self[Solrizer.solr_name('allow_hi_res', :symbol)]).first
    end

    def alt_text
      Array(self[Solrizer.solr_name('alt_text', :stored_searchable)])
    end

    def caption
      Array(self[Solrizer.solr_name('caption', :stored_searchable)])
    end

    def captions
      Array(self[Solrizer.solr_name('captions', :stored_searchable)]).first
    end

    def content_type
      Array(self[Solrizer.solr_name('content_type', :stored_searchable)])
    end

    def copyright_status
      Array(self[Solrizer.solr_name('copyright_status', :symbol)]).first
    end

    def credit_line
      Array(self[Solrizer.solr_name('credit_line', :symbol)]).first
    end

    def display_date
      Array(self[Solrizer.solr_name('display_date', :stored_searchable)])
    end

    def exclusive_to_platform
      Array(self[Solrizer.solr_name('exclusive_to_platform', :symbol)]).first
    end

    def external_resource_url
      Array(self[Solrizer.solr_name('external_resource_url', :symbol)]).first
    end

    def keywords
      Array(self[Solrizer.solr_name('keywords', :stored_searchable)])
    end

    def permissions_expiration_date
      Array(self[Solrizer.solr_name('permissions_expiration_date', :symbol)]).first
    end

    def primary_creator_role
      Array(self[Solrizer.solr_name('primary_creator_role', :stored_searchable)])
    end

    def redirect_to
      Array(self[Solrizer.solr_name('redirect_to', :symbol)]).first
    end

    def resource_type
      Array(self[Solrizer.solr_name('resource_type', :stored_searchable)]).first
    end

    def rights_granted
      Array(self[Solrizer.solr_name('rights_granted', :symbol)]).first
    end

    def section_title
      Array(self[Solrizer.solr_name('section_title', :stored_searchable)])
    end

    def sort_date
      Array(self[Solrizer.solr_name('sort_date', :stored_searchable)]).first
    end

    def transcript
      Array(self[Solrizer.solr_name('transcript', :stored_searchable)]).first
    end

    def translation
      Array(self[Solrizer.solr_name('translation', :stored_searchable)]).first
    end

    def descriptions
      Array(self[Solrizer.solr_name('descriptions', :stored_searchable)]).first
    end
  end
end
