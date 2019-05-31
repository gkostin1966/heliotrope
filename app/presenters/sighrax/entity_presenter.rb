# frozen_string_literal: true

class EntityPresenter
  def initialize(actor, entity)
    @actor = actor
    @entity = entity
  end

  def policy
    @policy ||= Policy.factory(@actor, @entity)
  end
end

