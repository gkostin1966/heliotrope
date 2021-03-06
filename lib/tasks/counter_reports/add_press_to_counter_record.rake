# frozen_string_literal: true

desc "Update old counter records to add press id"
namespace :heliotrope do
  task add_press_to_counter_record: :environment do
    CounterReport.where(press: nil).each do |cr|
      fp = Hyrax::PresenterFactory.build_for(ids: [cr.noid], presenter_class: Hyrax::FileSetPresenter, presenter_args: nil).first
      if fp.present?
        if fp.monograph.present?
          cr.press = Press.where(subdomain: fp.monograph.subdomain).first.id
          cr.save!
        else
          p "no monograph for file_set #{cr.noid}"
        end
      else
        p "no presenter for file_set #{cr.noid}"
      end
    end
  end
end
