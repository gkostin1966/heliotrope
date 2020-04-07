# frozen_string_literal: true

module BreadcrumbsHelper # rubocop:disable Metrics/ModuleLength
  mattr_accessor :crumbs

  def breadcrumbs # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    return [] if @presenter.nil?
    return [] if press.blank?
    @crumbs = []

    aboutware_home if has_aboutware?

    if press.parent_id.present?
      crumb_parent_press
    else
      crumb_press_home
    end

    case controller_name
    when "press_statistics"
      press_statistics
    when "score_catalog"
      work_catalog
    when "monograph_catalog"
      work_catalog
    when "monographs"
      curation_concerns_monograph_show
    when "file_sets"
      file_sets
    when "model_trees"
      model_trees
    end
    @crumbs
  end

  private

    def model_trees
      if @presenter.is_a?(Hyrax::FileSetPresenter)
        file_sets_show_model_tree
      else
        curation_concerns_show_model_tree
      end
    end

    def file_sets_show_model_tree
      if @presenter.parent.is_a? Hyrax::MonographPresenter
        @crumbs << { href: main_app.monograph_catalog_path(@presenter.parent.id), text: @presenter.parent.title, class: "" }
        @crumbs << { href: main_app.monograph_show_path(@presenter.parent.id), text: 'Show', class: "" }
      elsif @presenter.parent.is_a? Hyrax::ScorePresenter
        @crumbs << { href: main_app.score_catalog_path(@presenter.parent.id), text: @presenter.parent.title, class: "" }
        @crumbs << { href: main_app.score_show_path(@presenter.parent.id), text: 'Show', class: "" }
      end
      @crumbs << { href: main_app.hyrax_file_set_path(@presenter), text: @presenter.title }
      @crumbs << { href: "", text: 'Model', class: "active" }
    end

    def curation_concerns_show_model_tree
      if @presenter.is_a?(Hyrax::MonographPresenter)
        @crumbs << { href: main_app.monograph_catalog_path(@presenter), text: @presenter.title, class: "" }
        @crumbs << { href: main_app.monograph_show_path(@presenter), text: 'Show', class: "" }
      else
        @crumbs << { href: main_app.score_catalog_path(@presenter), text: @presenter.title, class: "" }
        @crumbs << { href: main_app.score_show_path(@presenter), text: 'Show', class: "" }
      end
      @crumbs << { href: "", text: 'Model', class: "active" }
    end

    def file_sets
      if @presenter.parent.is_a? Hyrax::MonographPresenter
        @crumbs << { href: main_app.monograph_catalog_path(@presenter.parent.id), text: @presenter.parent.title, class: "" }
        @crumbs << { href: main_app.monograph_show_path(@presenter.parent.id), text: 'Show', class: "" } if params[:parent_id].present?
      elsif @presenter.parent.is_a? Hyrax::ScorePresenter
        @crumbs << { href: main_app.score_catalog_path(@presenter.parent.id), text: @presenter.parent.title, class: "" }
        @crumbs << { href: main_app.score_show_path(@presenter.parent.id), text: 'Show', class: "" } if params[:parent_id].present?
      end
      @crumbs << { href: "", text: @presenter.title, class: "active" }
    end

    def curation_concerns_monograph_show
      @crumbs << { href: main_app.monograph_catalog_path(@presenter.id), text: @presenter.title, class: "" }
      @crumbs << { href: "", text: 'Show', class: "active" }
    end

    def work_catalog
      @crumbs << { href: "", text: @presenter.title, class: "active" }
    end

    def press_statistics
      @crumbs << { href: "", text: t('press_catalog.statistics'), class: "active" }
    end

    def crumb_parent_press
      parent = Press.find(press.parent_id)
      if has_aboutware?
        @crumbs << { href: main_app.press_catalog_path(parent), text: t('monograph_catalog.index.catalog'), class: "" }
      else
        @crumbs << { href: main_app.press_catalog_path(parent), text: t('monograph_catalog.index.home'), class: "" }
      end
      @crumbs << { href: main_app.press_catalog_path(press), text: press.name, class: "" }
    end

    def crumb_press_home
      if has_aboutware?
        @crumbs << { href: main_app.press_catalog_path(press), text: t('monograph_catalog.index.catalog'), class: "" }
      else
        @crumbs << { href: main_app.press_catalog_path(press), text: I18n.t('monograph_catalog.index.home'), class: "" }
      end
    end

    def aboutware_home
      @crumbs << { href: press.press_url, text: t('breadcumbs.home'), class: "" } if has_aboutware?
    end

    def has_aboutware?
      press.aboutware?
    end

    def press
      @press ||= if defined?(@presenter.subdomain)
                   Press.where(subdomain: @presenter.subdomain)&.first
                 elsif defined?(@presenter.parent.subdomain)
                   Press.where(subdomain: @presenter.parent.subdomain)&.first
                 else
                   ""
                 end
    end
end
