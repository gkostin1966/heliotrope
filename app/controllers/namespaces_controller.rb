# frozen_string_literal: true

class NamespacesController < ApplicationController
  def dashboard
    @press = Press.find_by(subdomain: params[:namespace])
  end
end
