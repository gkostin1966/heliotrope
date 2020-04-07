# frozen_string_literal: true

class ModelTreesController < ApplicationController
  before_action :set_model_tree, only: %i[show update destroy link]

  def show
  end

  def kind
    ModelTreeService.new.kind(params[:id], params[:kind])
    redirect_to model_tree_path(params[:show_id] || params[:id]), notice: 'Kind was successfully set.'
  end

  def unkind
    ModelTreeService.new.kind(params[:id])
    redirect_to model_tree_path(params[:show_id] || params[:id]), notice: 'Kind was successfully unset.'
  end

  def link
    # Services.modeling.link(params[:parent_id], params[:id])
    ModelTreeService.new.link(params[:parent_id] || params[:id], params[:child_id])
    redirect_to model_tree_path(params[:id]), notice: 'Link was successfully created.'
  end

  def unlink
    # Services.modeling.unlink_parent(params[:id])
    ModelTreeService.new.unlink_parent(params[:id])
    redirect_to model_tree_path(params[:show_id] || params[:id]), notice: 'Link was successfully deleted.'
  end

  private

    def set_model_tree
      @entity = Sighrax.from_noid(params[:id])
      @press = Sighrax.press(@entity) # needed for boilerplate layout
      @hyrax_presenter = Sighrax.hyrax_presenter(@entity) # needed for breadcrumbs helper
      @model_tree = ModelTree.from_entity(@entity) # Rails convention
      @presenter = ModelTreePresenter.new(current_actor, @model_tree) # Heliotrope convention
    end

    def model_tree_params
      params.require(:model_tree).permit(:parent_id, :child_id, :show_id, :kind)
    end
end
