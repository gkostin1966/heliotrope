# frozen_string_literal: true

class EPubsController < ApplicationController
  after_action :allow_feedback_google_form_iframe

  def show
    @presenter = Hyrax::FileSetPresenter.new(SolrDocument.new(FileSet.find(params[:id]).to_solr), current_ability, request)
    if @presenter.epub?
      FactoryService.e_pub_publication(params[:id]) # cache epub
      @title = @presenter.parent.present? ? @presenter.parent.title : @presenter.title
      @citable_link = @presenter.citable_link
      @creator_given_name = @presenter.creator_given_name
      @creator_family_name = @presenter.creator_family_name
      @back_link = params[:publisher].present? ? URI.join(main_app.root_url, params[:publisher]).to_s : main_app.monograph_catalog_url(@presenter.monograph_id)
      @subdomain = @presenter.monograph.subdomain
      @search_url = main_app.epub_search_url(params[:id], q: "").gsub!(/locale=en&/, '')
      @monograph_presenter = nil
      if @presenter.parent.present?
        @monograph_presenter = Hyrax::PresenterFactory.build_for(ids: [@presenter.parent.id], presenter_class: Hyrax::MonographPresenter, presenter_args: current_ability).first
      end
      @feedback_modal = true
      @feedback_iframe = '<iframe src="https://docs.google.com/forms/d/e/1FAIpQLSdjp1THLBXgs8aj3g0jws35ratvO4Pb4bEQS6ABY7AgeJ0xvA/viewform?embedded=true#start=embed" width="870" height="700" frameborder="0" marginheight="0" marginwidth="0">Loading...</iframe>'.html_safe # rubocop:disable Rails/OutputSafety
      render layout: false
    else
      Rails.logger.info("EPubsController.show(#{params[:id]}) is not an EPub.")
      render 'hyrax/base/unauthorized', status: :unauthorized
    end
  rescue Ldp::Gone # tombstone
    raise CanCan::AccessDenied
  end

  def file
    render plain: FactoryService.e_pub_publication(params[:id]).read(params[:file] + '.' + params[:format]), content_type: Mime::Type.lookup_by_extension(params[:format]), layout: false
  rescue StandardError => e
    Rails.logger.info("EPubsController.file(#{params[:file] + '.' + params[:format]}) mapping to 'Content-Type': #{Mime::Type.lookup_by_extension(params[:format])} raised #{e}")
    head :no_content
  end

  def search
    if Rails.env == 'development'
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'GET'
      headers['Access-Control-Request-Method'] = '*'
    end
    results = FactoryService.e_pub_publication(params[:id]).search(params[:q])
    if results[:search_results]
      render json: results
    else
      head :not_found
    end
  end

  private

    def allow_feedback_google_form_iframe
      response.headers['X-Frame-Options'] = 'https://docs.google.com'
    end
end
