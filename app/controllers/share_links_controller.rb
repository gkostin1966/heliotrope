# frozen_string_literal: true

class ShareLinksController < ApplicationController

  def create

    csv = manifest_params[:csv] if params[:manifest].present?
    @manifest = Manifest.new(params[:id], csv)
    if csv.present?
      notice = "Error" unless @manifest.create(current_user)
      redirect_to monograph_manifests_path, notice: notice
    else
      flash[:notice] = "No file chosen"
      render :new
    end
  end

  private

    def share_link_params
      params.require(:share_link).permit(:jwt)
    end
end
