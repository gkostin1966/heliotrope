# frozen_string_literal: true

class MonographSearchBuilder < ::SearchBuilder
  self.default_processor_chain += [:filter_by_members]

  def filter_by_members(solr_parameters)
    ids = if blacklight_params[:monograph_id]
            # used for the facets "more" link and facet modal
            asset_ids(blacklight_params[:monograph_id])
          else
            asset_ids(blacklight_params['id'])
          end
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "{!terms f=id}#{ids}"
  end

  private

    # Get the asset/fileset ids of the monograph
    def asset_ids(id) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      monograph = Hyrax::PresenterFactory.build_for(ids: [id], presenter_class: Hyrax::MonographPresenter, presenter_args: nil).first
      return if monograph.blank?

      docs = monograph.ordered_member_docs
      return if docs.blank?

      ids = []
      docs.each do |doc|
        fp = Hyrax::FileSetPresenter.new(doc, nil)
        can_not_edit = !current_ability.can?(:edit, fp.id)
        next if fp.featured_representative? && can_not_edit
        next if fp.id == monograph.representative_id && can_not_edit
        next if Sighrax.tombstone?(Sighrax.from_presenter(fp))
        ids << fp.id
      end

      ids.join(",")
    end

    def work_types
      [FileSet]
    end
end
