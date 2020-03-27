# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.include CheckpointSpecHelper
  config.include RequestSpecHelper, type: :request
  config.include SystemSpecHelper, type: :system
  config.include IntegrationSpecHelper, type: :integration

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view
  config.include Devise::Test::IntegrationHelpers, type: :system
  config.include Warden::Test::Helpers, type: :feature
  config.include RSpecHtmlMatchers
end

# Stub out anything that requires a redis connection,
# such as background jobs and lock management.
def stub_out_redis
  allow(IngestJob).to receive_messages(perform_later: nil, perform_now: nil)
  allow(CharacterizeJob).to receive_messages(perform_later: nil, perform_now: nil)
  allow(ContentEventJob).to receive_messages(perform_later: nil, perform_now: nil)
  allow(ContentDeleteEventJob).to receive_messages(perform_later: nil, perform_now: nil)
  allow_any_instance_of(Hyrax::Actors::FileSetActor).to receive(:acquire_lock_for).and_yield
  allow_any_instance_of(AttachImportFilesToWorkJob).to receive(:acquire_lock_for).and_yield
end

# For system specs

# On system spec failure, don't dump the (binary!) screenshot to the console,
# just save it to disk which is probably ~/tmp/screenshots
ENV['RAILS_SYSTEM_TESTING_SCREENSHOT'] = "simple"

require 'capybara/rspec'
require 'webdrivers'
require 'selenium-webdriver'

# Needed for session/cookies, in version 4 we won't need this anymore
Webdrivers.cache_time = 86_400

# We need a large screen size for CozySunBear system specs in order to get 2-up
# pages and other things
# https://stackoverflow.com/a/47290251

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  [
    "headless",
    "window-size=1280x1280",
    "disable-gpu" # https://developers.google.com/web/updates/2017/04/headless-chrome
  ].each { |arg| options.add_argument(arg) }

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :headless_chrome
