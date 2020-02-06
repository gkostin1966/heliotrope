# frozen_string_literal: true

include Rails.application.routes.url_helpers

desc 'Find EPUBS using absolute sizing (x-small, small, medium, large, x-large) to set font-size.'
namespace :heliotrope do
  task find_epubs: :environment do
    Dir.glob(Rails.root.join("tmp", "derivatives", "*", "*", "*", "*", "*-epub")).each do |path|
      Find.find(path) do |p|
        next unless /.*\.css$/.match?(p)
        File.open p do |file|
          found = false
          file.find_all do |line|
            next unless /\bfont-size:\b(x-small|small|medium|large|x-large)\b/i.match?(line)
            found = true
            break
          end
          if found
            noid = UnpackService.noid_from_root_path(path, 'epub')
            epub = Sighrax.factory(noid)
            monograph = epub.parent
            puts noid + ',' + p + ',' +
            if epub.is_a?(Sighrax::NullEntity)
              ',,,,,'
            else
              epub_url(epub.noid) + ',' + created(epub).to_s + ',' + modified(epub).to_s + ',' +
              if monograph.is_a?(Sighrax::NullEntity)
                ',,'
              else
                Sighrax.press(monograph).subdomain + ',' + hyrax_monograph_url(monograph.noid) + ',"' + monograph.title + '"'
              end
            end
          end
        end
      end
    end
  end
end

def created(entity)
  Array(entity.send(:data)['date_uploaded_dtsi']).first
end

def modified(entity)
  Array(entity.send(:data)['date_modified_dtsi']).first
end
