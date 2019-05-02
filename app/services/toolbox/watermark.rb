# frozen_string_literal: true

module Toolbox
  class << self
    def watermark(media, media_type, metadata)
      return media unless /^application\/pdf$/.match?(media_type)
      t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      pdf = CombinePDF.parse(media)
      stamp = CombinePDF.create_page

      title = metadata[:title] || ''
      press = metadata[:press] || ''
      request_origin = metadata[:request_origin] || ''
      size = 12

      stamp.textbox("#{title}".encode('ASCII-8BIT', invalid: :replace, undef: :replace, replace: '_'), # rubocop:disable Style/UnneededInterpolation
                    font: :"Times-Roman",
                    font_size: size,
                    max_font_size: size,
                    text_align: :left,
                    text_valign: :center,
                    x: size, y: 3 * size,
                    width: size, height: size,
                    # border_color: [0.5, 0.5, 0.5],
                    # border_width: size,
                    opacity: 0.25)

      stamp.textbox("#{press}. All rights reserved.".encode('ASCII-8BIT', invalid: :replace, undef: :replace, replace: '_'),
                    font: :"Times-Roman",
                    font_size: size,
                    max_font_size: size,
                    text_align: :left,
                    text_valign: :center,
                    x: size, y: 2 * size,
                    width: size, height: size,
                    # border_color: [0.5, 0.5, 0.5],
                    # border_width: size,
                    opacity: 0.25)

      stamp.textbox("Downloaded on behalf of #{request_origin}".encode('ASCII-8BIT', invalid: :replace, undef: :replace, replace: '_'),
                    font: :"Times-Roman",
                    font_size: size,
                    max_font_size: size,
                    text_align: :left,
                    text_valign: :center,
                    x: size, y: size,
                    width: size, height: size,
                    # border_color: [0.5, 0.5, 0.5],
                    # border_width: size,
                    opacity: 0.25)

      pdf.stamp_pages(stamp)

      t2 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      Rails.logger.debug("[PDF WATERMARK] took #{t2 - t1} seconds")

      pdf.to_pdf
    rescue StandardError => e
      Rails.logger.error "Toolbox.watermark raised #{e}"
      media
    end
  end
end
