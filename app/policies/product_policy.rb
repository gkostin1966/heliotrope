# frozen_string_literal: true

class ProductPolicy
  def initialize(product)
    @actor = {}
    @target = { product: product }
  end

  def authorize!(action, message = nil)
    return if action_permitted?(action)
    raise(NotAuthorizedError, message)
  end

  def show?
    action_permitted?(:read)
  end

  private

    def action_permitted?(action)
      Checkpoint::Query::ActionPermitted.new(actor, action, target, authority: authority).true?
    rescue StandardError => e
      Rails.logger.error "EPubPolicy::action_permitted?(#{action}) #{e}"
      false
    end

    def authority
      @authority ||= Checkpoint::Authority.new(agent_resolver: ActorAgentResolver.new, resource_resolver: TargetResourceResolver.new)
    end

    attr_reader :actor, :target
end
