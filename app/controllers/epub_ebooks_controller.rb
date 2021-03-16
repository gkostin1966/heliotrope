# frozen_string_literal: true

class EpubEbooksController < CheckpointController
  before_action :setup

  def show
    @policy.authorize! :show?

    @presenter = Sighrax.hyrax_presenter(@epub_ebook, current_ability)
    @parent_presenter = Sighrax.hyrax_presenter(@epub_ebook.parent, current_ability)
    @title = @presenter.parent.present? ? @presenter.parent.page_title : @presenter.page_title
    @citable_link = @parent_presenter.citable_link
    @back_link = if params[:publisher].present?
                   URI.join(main_app.root_url, params[:publisher]).to_s
                 else
                   @presenter.parent.catalog_url
                 end
    @ebook_download_presenter = EbookDownloadPresenter.new(@parent_presenter, current_ability, current_actor)

    CounterService.from(self, @presenter).count(request: 1)

    render layout: false
  end

  def download
    raise NotAuthorizedError unless @policy.download?
    redirect_to(hyrax.download_path(params[:id]))
  end

  def setup
    @epub_ebook = Sighrax.from_noid(params[:id])
    @policy = EpubEbookPolicy.new(current_actor, @epub_ebook)
  end
end
