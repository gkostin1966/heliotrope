# frozen_string_literal: true

class EbooksController < CheckpointController
  before_action :setup

  def download
    raise NotAuthorizedError unless @policy.download?
    return redirect_to(hyrax.download_path(params[:id])) unless Sighrax.watermarkable?(@entity) && @press_policy.watermark_download?
    begin
      watermarked = Rails.cache.fetch(cache_key, expires_in: 30.days) do
        # Toolbox.watermark(@entity.content, @entity.media_type, title: @entity.parent.title, press: @press.name, request_origin: request_origin)
        t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)

        text = <<~WATERMARK
          #{@entity.parent.title}
          Copyright \u00A9 #{@press.name}. All rights reserved.
          Downloaded on behalf of #{request_origin}
        WATERMARK

        pdf = CombinePDF.parse(@entity.content, allow_optional_content: true)
        stamp = CombinePDF.parse(watermark(text)).pages[0]
        pdf.stamp_pages(stamp)

        t2 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        Rails.logger.debug("[PDF WATERMARK] took #{t2 - t1} seconds")

        pdf.to_pdf
      end

      send_data watermarked, type: @entity.media_type, filename: @entity.filename
    rescue StandardError => e
      Rails.logger.error "EbooksController.download raised #{e}"
      head :no_content
    end
  end

  private

    def setup
      @entity = Sighrax.factory(params[:id])
      @policy = Sighrax.policy(current_actor, @entity)
      @press = Sighrax.press(@entity)
      @press_policy = PressPolicy.new(current_actor, @press)
    end

    def cache_key
      @entity.noid + '-' +
        Digest::MD5.hexdigest(@entity.resource_token) + '-' +
        Digest::MD5.hexdigest(@entity.parent.title) + '-' +
        Digest::MD5.hexdigest(request_origin)
    end

    def request_origin
      @request_origin ||= current_institution&.name || request.remote_ip
    end

    def watermark(text)
      size = 9
      height = (text.lines.count + 1) * size
      width = 0
      text.lines.each do |line|
        width = (width < line.size) ? line.size : width
      end
      width *= (size / 2)
      pdf = Prawn::Document.new do
        Prawn::Font::AFM.hide_m17n_warning = true
        font('Times-Roman', size: size) do
          bounding_box([0, height], width: width, height: height) do
            transparent(0.5) do
              fill_color "ffffff"
              stroke_color "ffffff"
              fill_rectangle [-size, height + size], width + (2 * size), height + size
              fill_color "000000"
              stroke_color "000000"
              text text
            end
          end
        end
      end
      pdf.render
    end
end
