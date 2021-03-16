# frozen_string_literal: true

# See en.csv.descriptions in ./config/locales/heliotrope.en.yml for metadata field descriptions

module Sighrax
  class Monograph < Work
    private_class_method :new

    def contributors
      vector('creator_tesim') + vector('contributor_tesim')
    end

    def cover_representative
      @cover_representative ||= Sighrax.from_noid(Array(data['representative_id_ssim']).first, reload)
    end

    def description
      scalar('description_tesim') || ''
    end

    def epub_featured_representative
      @epub_featured_representative ||= Sighrax.from_noid(FeaturedRepresentative.find_by(work_id: noid, kind: 'epub')&.file_set_id, reload)
    end

    def identifier
      return @identifier if @identifier.present?

      @identifier = HandleNet::DOI_ORG_PREFIX + scalar('doi_ssim') if scalar('doi_ssim').present?
      @identifier ||= HandleNet::HANDLE_NET_PREFIX + scalar('hdl_ssim') if scalar('hdl_ssim').present?
      @identifier ||= HandleNet.url(noid)
      @identifier
    end

    def languages
      vector('language_tesim')
    end

    def modified
      # Going to leverage the aptrust_deposits table updated_at field
      # since this is the modify date of the entire monograph a.k.a.
      # Maximum date_modified_dtsi of the Monograph and all its FileSets. .
      record = AptrustDeposit.find_by(noid: noid)
      return record.updated_at.utc if record.present?

      super
    end

    def open_access?
      /^yes$/i.match?(scalar('open_access_tesim'))
    end

    def pdf_ebook_featured_representative
      @pdf_ebook_featured_representative ||= Sighrax.from_noid(FeaturedRepresentative.find_by(work_id: noid, kind: 'pdf_ebook')&.file_set_id, reload)
    end

    def products
      Greensub::Product.containing_monograph(noid)
    end

    def publication_year
      match = /(\d{4})/.match(scalar('date_created_tesim'))
      return match[1] if match.present?

      nil
    end

    def published
      Time.parse(scalar('date_published_dtsim')).utc
    rescue StandardError => _e
      nil
    end

    # This solr field 'publisher_tesim' is the name of the company that created the work.
    # Not to be confused with 'subdomain' which is the 'press' a.k.a. Fulcrum Publisher.
    def publishing_house
      scalar('publisher_tesim') || ''
    end

    def restricted?
      Greensub::Component.find_by(noid: noid).present?
    end

    def series
      scalar('series_tesim') || ''
    end

    def subjects
      vector('subject_tesim')
    end

    private

      def initialize(noid, data, reload = true)
        super(noid, data, reload)
      end
  end
end
