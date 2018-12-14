# frozen_string_literal: true

module Bloodstone
  class << self
    def debug_log(msg)
      Rails.logger.debug "[BLOODSTONE] -- #{msg}"
    end
  end
end
