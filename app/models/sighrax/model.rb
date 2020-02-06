# frozen_string_literal: true

module Sighrax
  class Model < Entity
    private_class_method :new

    def title
      Array(data['title_tesim']).first || super
    end

    # # hyrax/app/models/concerns/hyrax
    # #
    # # We reserve date_uploaded for the original creation date of the record.
    # # For example, when migrating data from a fedora3 repo to fedora4,
    # # fedora's system created date will reflect the date when the record
    # # was created in fedora4, but the date_uploaded will preserve the
    # # original creation date from the old repository.
    # property :date_uploaded, predicate: ::RDF::Vocab::DC.dateSubmitted, multiple: false do |index|
    #   index.type :date
    #   index.as :stored_sortable
    # end
    #
    # property :date_modified, predicate: ::RDF::Vocab::DC.modified, multiple: false do |index|
    #   index.type :date
    #   index.as :stored_sortable
    # end

    def created
      Array(data['date_uploaded_dtsi']).first
    end

    def modified
      Array(data['date_modified_dtsi']).first
    end

    protected

      def model_type
        Array(data['has_model_ssim']).first
      end

    private

      def initialize(noid, data)
        super(noid, data)
      end
  end
end
