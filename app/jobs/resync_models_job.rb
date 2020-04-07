# frozen_string_literal: true

class ResyncModelsJob < ApplicationJob
  def perform(target)
    case target
    when 'monographs'
      Monograph.all.each do |monograph|
        resync_model(monograph.id)
      end
    else
      noids = [target].flatten
      noids.each do |noid|
        resync_model(noid)
      end
    end
  end

  private

    def resync_model(noid) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      # Create Model Tree Vertices and Edges for Work Featured Representatives
      FeaturedRepresentative.where(work_id: noid).each do |fr|
        if ModelTreeEdge.where(parent_noid: fr.work_id, child_noid: fr.file_set_id).blank?
          ModelTreeEdge.create(parent_noid: fr.work_id, child_noid: fr.file_set_id)
        end

        parent = ModelTreeVertex.find_or_create_by(noid: fr.work_id)
        parent.representative = false # Works are never representatives
        parent.save

        child = ModelTreeVertex.find_or_create_by(noid: fr.file_set_id)
        child.representative = true
        child.save
      end

      # Create Model Tree Vertices and Edges for File Set Featured Representatives
      FeaturedRepresentative.where(file_set_id: noid).each do |fr|
        if ModelTreeEdge.where(parent_noid: fr.work_id, child_noid: fr.file_set_id).blank?
          ModelTreeEdge.create(parent_noid: fr.work_id, child_noid: fr.file_set_id)
        end

        _parent = ModelTreeVertex.find_or_create_by(noid: fr.work_id)

        child = ModelTreeVertex.find_or_create_by(noid: fr.file_set_id)
        child.representative = true
        child.save
      end

      # Destroy Model Tree Vertices and Edges without Featured Representatives
      children = []
      orphans = []
      parent = false
      ModelTreeEdge.where(parent_noid: noid).each do |e|
        if FeaturedRepresentative.where(work_id: e.parent_noid, file_set_id: e.child_noid).present?
          children << e.child_noid
          parent = true
        else
          orphans << e.child_noid
          e.destroy
        end
      end

      child = false
      ModelTreeEdge.where(child_noid: noid).each do |e|
        if FeaturedRepresentative.where(work_id: e.parent_noid, file_set_id: e.child_noid).present?
          parent = ModelTreeVertex.find_or_create_by(noid: e.parent_noid)
          child = true
        else
          e.destroy
        end
      end

      unless parent || child
        ModelTreeVertex.find_by(noid: noid)&.destroy
      end

      children.each do |kid|
        v = ModelTreeVertex.find_or_create_by(noid: kid)
        v.representative = true
        v.save
      end

      orphans.each do |orphan|
        parent = FeaturedRepresentative.where(work_id: orphan).present?
        child = FeaturedRepresentative.where(file_set_id: orphan).present?

        if parent || child
          v = ModelTreeVertex.find_or_create_by(noid: orphan)
          v.representative = child
          v.save
        else
          ModelTreeVertex.find_by(noid: orphan)&.destroy
        end
      end

      true
    end
end
