# frozen_string_literal: true

class OpenAccessPolicy
  def initialize(noid)
    @actor = {}
    @target = { noid: noid }
  end

  def authorize!(action, message = nil)
    return if action_permitted?(action)
    raise(NotAuthorizedError, message)
  end

  def open_access?
    action_permitted?(:read)
  end

  def open_access
    return if open_access?
    authority.permits(actor, :read, target)
  end

  def restrict_access
    return unless open_access?
    authority.prohibits(actor, :read, target)
  end

  private

    def action_permitted?(action)
      Checkpoint::Query::ActionPermitted.new(actor, action, target, authority: authority).true?
    rescue StandardError => e
      Rails.logger.error "OpenAccessPolicy::action_permitted?(#{action}) #{e}"
      false
    end

    def authority
      @authority ||= Checkpoint::Authority.new(agent_resolver: ActorAgentResolver.new, resource_resolver: TargetResourceResolver.new)
    end

    attr_reader :actor, :target
end
