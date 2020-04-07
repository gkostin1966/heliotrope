# frozen_string_literal: true

class ModelTreeService
  def kind(noid, kind = nil)
    vertex = ModelTreeVertex.find_by(noid: noid)

    hash = get_data(vertex)
    hash[:kind] = kind
    set_data(vertex, hash)
  end

  def link(parent_noid, child_noid)
    edge = ModelTreeEdge.find_by(parent_noid: parent_noid, child_noid: child_noid)
    return true if edge.present?

    child_has_parent = ModelTreeEdge.find_by(child_noid: child_noid).present?
    return false if child_has_parent

    _edge = ModelTreeEdge.create(parent_noid: parent_noid, child_noid: child_noid)
    _parent = ModelTreeVertex.find_or_create_by(noid: parent_noid)
    _child = ModelTreeVertex.find_or_create_by(noid: child_noid)

    active_fedora_link(parent_noid, child_noid)

    true
  end

  def unlink_parent(child_noid)
    edge = ModelTreeEdge.find_by(child_noid: child_noid)
    return true if edge.blank?

    parent = ModelTreeVertex.find_by(noid: edge.parent_noid)
    child = ModelTreeVertex.find_by(noid: edge.child_noid)
    edge.destroy

    parent_has_child = ModelTreeEdge.where(parent_noid: parent&.noid).present?
    parent_is_child = ModelTreeEdge.where(child_noid: parent&.noid).present?
    parent&.destroy unless parent_has_child || parent_is_child

    child_is_parent = ModelTreeEdge.where(parent_noid: child&.noid).present?
    child&.destroy unless child_is_parent

    active_fedora_unlink_parent(child_noid)

    true
  end

  def unlink_children(parent_noid)
    edges = ModelTreeEdge.where(parent_noid: parent_noid)
    edges.each do |edge|
      unlink_parent(edge.child_noid)
    end
    true
  end

  def select_parent_options(noid)
    return [] if ModelTreeEdge.find_by(child_noid: noid).present?

    root_entity = root_entity(noid)
    return [] if root_entity.noid == noid

    exclusions = ModelTreeEdge.where(parent_noid: noid).pluck(:child_noid).prepend(noid)

    root_entity.children_noids.prepend(root_entity.noid).reject { |n| exclusions.include?(n) }
  end

  def select_child_options(noid)
    root_entity = root_entity(noid)
    return [] if root_entity.is_a?(Sighrax::NullEntity)

    exclusions = ModelTreeEdge.pluck(:child_noid).prepend(noid)
    parent_noid = ModelTreeEdge.find_by(child_noid: noid)&.parent_noid
    exclusions = exclusions.prepend(parent_noid) if parent_noid.present?

    root_entity.children_noids.reject { |n| exclusions.include?(n) }
  end

  private

    def root_entity(noid)
      root_entity = Sighrax.from_noid(noid)
      until root_entity.parent.is_a?(Sighrax::NullEntity) do
        root_entity = root_entity.parent
      end
      root_entity
    end

    def get_data(vertex)
      return {} if vertex.blank?

      JSON.parse(vertex.data)
    end

    def set_data(vertex, hash = {})
      return {} if vertex.blank?

      vertex.data = hash.to_json
      vertex.save
      active_fedora_set_data(vertex.noid, hash)
    end

    def active_fedora_set_data(noid, hash)
      vertex = ActiveFedora::Base.find(noid)
      json = hash.to_json unless hash.empty?
      vertex.model_metadata_json = json
      vertex.save!
    end

    def active_fedora_link(parent_noid, child_noid)
      child = ActiveFedora::Base.find(child_noid)
      child.model_parent_noid = parent_noid
      child.save!
    end

    def active_fedora_unlink_parent(child_noid)
      child = ActiveFedora::Base.find(child_noid)
      child.model_parent_noid = nil
      child.save!
    end
end
