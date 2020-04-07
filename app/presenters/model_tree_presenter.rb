# frozen_string_literal: true

class ModelTreePresenter < ApplicationPresenter
  attr_reader :model_tree
  attr_reader :press

  delegate :id, :noid, :entity, :kind?, :kind, :parent?, :children?, :representative?, to: :model_tree

  def initialize(current_user, model_tree)
    super(current_user)
    @model_tree = model_tree
  end

  def display_name
    entity.title
  end

  def representatives
    children
  end

  def parent
    @parent ||= ModelTreePresenter.new(current_user, model_tree.parent)
  end

  def children
    @children ||= model_tree.children.map { |child| ModelTreePresenter.new(current_user, child) }
  end

  def kind_display
    kind_display_map(kind)
  end

  def kind_options
    %w[cover epub pdf captions descriptions transcript].map { |k| [kind_display_map(k), k] }
  end

  def parent_options
    ModelTreeService.new.select_parent_options(noid).map { |n| [Sighrax.from_noid(n).title, n] }
  end

  def child_options?
    child_options.present?
  end

  def child_options
    @child_options ||= ModelTreeService.new.select_child_options(noid).map { |n| [Sighrax.from_noid(n).title, n] }
  end

  private

    def kind_display_map(kind) # rubocop:disable Metrics/CyclomaticComplexity
      case kind
      when 'epub'
        'electronic publication (EPUB)'
      when 'pdf'
        'portable document format (PDF)'
      when 'cover'
        'thumbnail'
      when 'captions'
        'closed captions'
      when 'descriptions'
        'audio descriptions'
      when 'transcript'
        'transcript'
      end
    end
end
