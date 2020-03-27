# frozen_string_literal: true

module IntegrationSpecHelper
  def self.included(base)
    base.before(:all) do
      RSpec.configuration.use_active_fedora_cleaner = false
    end

    base.after(:all) do
      RSpec.configuration.use_active_fedora_cleaner = true
    end
  end
end
