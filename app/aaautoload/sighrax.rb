# frozen_string_literal: true

module Sighrax
  class << self
    def factory(noid)
      noid = noid&.to_s
      return Sighrax::Entity.null_entity(noid) unless ValidationService.valid_noid?(noid)

      entity = begin
        ActiveFedora::SolrService.query("{!terms f=id}#{noid}", rows: 1).first
      rescue StandardError => _e
        nil
      end
      return Sighrax::Entity.null_entity(noid) if entity.blank?

      model_type = entity['has_model_ssim']&.first
      return Sighrax::Entity.send(:new, noid, entity) if model_type.blank?
      model_factory(noid, entity, model_type)
    end

    def hyrax_can?(actor, action, target)
      return false if actor.is_a?(Anonymous)
      return false unless /read/i.match?(action.to_s)
      return false unless target.valid?
      ability = Ability.new(actor)
      ability.can?(action.to_s.to_sym, target.noid)
    end

    def subdomain(entity)
      press_subdomain = entity.entity['press_tesim']&.first
      debug_log("subdomain: press_subdomain: #{press_subdomain}")
      return press_subdomain if press_subdomain.present?
      monograph_id = entity.entity['monograph_id_ssim']&.first
      debug_log("subdomain: monograph_id: #{monograph_id}")
      return Sighrax.subdomain(Sighrax.factory(monograph_id)) if monograph_id.present?
      debug_log("subdomain: ")
      ''
    end

    def published?(entity)
      entity.valid? && entity.entity['suppressed_bsi'] == false && /open/i.match?(entity.entity['visibility_ssi'])
    end

    def restricted?(entity)
      entity.valid? && Component.find_by(noid: entity.noid).present?
    end

    def debug_log(msg)
      Rails.logger.debug "[SIGHRAX] -- #{msg}"
    end

    private

    def model_factory(noid, entity, model_type)
      if /Monograph/i.match?(model_type)
        Sighrax::Monograph.send(:new, noid, entity)
      elsif /FileSet/i.match?(model_type)
        file_set_factory(noid, entity)
      else
        Sighrax::Model.send(:new, noid, entity)
      end
    end

    def file_set_factory(noid, entity)
      featured_representative = FeaturedRepresentative.find_by(file_set_id: noid)
      return Sighrax::Asset.send(:new, noid, entity) if featured_representative.blank?
      case featured_representative.kind
      when 'epub'
        Sighrax::ElectronicPublication.send(:new, noid, entity)
      else
        Sighrax::Asset.send(:new, noid, entity)
      end
    end
  end
end
