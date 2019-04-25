# frozen_string_literal: true

class DeleteActiveFedoraObjectsJob < ApplicationJob
  def perform(ids, destroy = false)
    delete_or_destroy = destroy ? :destroy : :delete
    ids.each do |id|
      begin
        ActiveFedora::Base.find(id).public_send(delete_or_destroy)
      rescue Ldp::Gone
        Rails.logger.error("ERROR DeleteActiveFedoraObjectsJob ActiveFedora::Base.find(#{id})) --> Ldp::Gone")
      end
    end
  end
end
