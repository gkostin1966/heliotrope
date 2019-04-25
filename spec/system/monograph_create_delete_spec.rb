# frozen_string_literal: true

require 'rails_helper'

def create_monograph(title)
  visit concern_monographs_new_path
  expect(page).to have_content('Add New Monograph')

  fill_in 'Title', with: title
  select press.name, from: 'Publisher'
  fill_in 'Creator(s)', with: "Johns, Jimmy\nWay, Sub (editor)"
  fill_in 'Publisher', with: 'Blah Press, Co.'
  fill_in 'Publication Year', with: '2001'
  fill_in 'Publication Location', with: 'Ann Arbor, MI.'

  click_on 'Files'
  within '#addfiles' do
    attach_file('files[]', File.absolute_path('./spec/fixtures/csv/shipwreck.jpg'), multiple: true, make_visible: true)
  end

  choose 'monograph_visibility_open'
  check 'I have read'
  click_on 'Save'
  expect(page).to have_content 'Your files are being processed by Fulcrum in the background.'
end

def delete_monograph(monograph)
  visit monograph_catalog_path(monograph)
  expect(page).to have_content(monograph.title.first)

  click_on 'Manage Monograph and Files'
  expect(page).to have_content "Home #{monograph.title.first} Show"

  click_on 'Delete'
  page.driver.browser.switch_to.alert.accept

  expect(page).to have_content "Deleted #{monograph.title.first}"
end

def puts_bases
  ActiveFedora::Base.all.each_with_index do |thing, index|
    puts "#{index} #{thing} --> #{thing.id}"
  end
  puts "ActiveFedora::Base.count #{ActiveFedora::Base.count}"
  puts ''
end

RSpec.describe "Monograph Create Delete", type: :system do
  let(:user) { create(:platform_admin) }
  let(:press) { create(:press, subdomain: 'blue') }

  before do
    # Don't print/puts status messages during specs
    allow($stdout).to receive(:puts)
    allow($stdout).to receive(:print)
    ActiveFedora::Cleaner.clean!
    sign_in user
  end

  # Comment this method out to see screenshots on failures in tmp/screenshots
  def take_failed_screenshot
    false
  end

  it "creates and deletes a monograph" do
    expect(ActiveFedora::Base.count).to be_zero

    puts "ActiveFedora::Base.count #{ActiveFedora::Base.count}"
    puts ''

    visit press_catalog_path(press)
    expect(page).to have_content('No entries found')

    create_monograph('Monograph One')
    expect(ActiveFedora::Base.count).to eq(23)

    puts "Monograph One Created"
    puts_bases

    create_monograph('Monograph Two')
    expect(ActiveFedora::Base.count).to eq(43)

    puts "Monograph Two Created"
    puts_bases

    ids = []
    ActiveFedora::Base.all.each do |thing|
      ids << thing.id
    end

    Monograph.all.each do |monograph|
      delete_monograph(monograph)
      puts "#{monograph.title.first} Deleted"
      puts_bases
    end

    ids.each do |id|
      begin
        puts "#{ActiveFedora::Base.find(id)} --> #{id}"
      rescue Ldp::Gone
        puts "Ldp::Gone --> #{id}"
      rescue StandardError => e
        puts "error #{e} --> #{id}"
      end
    end

    fedora_contains = RestfulFedora::Service.new.contains
    puts "Fedora contains"
    puts fedora_contains.inspect
    puts ''

    puts "Solr contains"
    solr_contains = RestfulSolr::Service.new.contains
    puts solr_contains.inspect
    puts ''

    puts "ActiveFedora::Base.count #{ActiveFedora::Base.count}"
    puts ''
    expect(ActiveFedora::Base.count).to eq(3) # AdminSet, AccessControl, and Permission

    ActiveFedora::Cleaner.clean!
  end
end
