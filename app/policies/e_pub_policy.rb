# frozen_string_literal: true

class EPubPolicy < ResourcePolicy
  def initialize(actor, target, share = false)
    target = target.parent
    super(actor, target)
    @share = share
  end

  def show? # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    debug_log("show? #{actor.agent_type}:#{actor.agent_id}, #{target.resource_type}:#{target.resource_id}, share is #{share}")

    value = super
    debug_log("platform_admin? #{value}")
    return true if value

    value = target.published?
    debug_log("published? #{value}")
    if value
      value = target.open_access?
      debug_log("open_access? #{value}")
      return true if value

      value = target.unrestricted?
      debug_log("unrestricted? #{value}")
      return true if value

      value = Sighrax.ability_can?(actor, :edit, target) && Incognito.allow_ability_can?(actor)
      debug_log("ability_can(:edit)? #{value}")
      return true if value

      debug_log("share #{share}")
      return true if share

      component = Greensub::Component.find_by(noid: target.noid)
      debug_log("component products: #{component.products.count}")
      component.products.each { |product| debug_log("component product: #{product.identifier}") }

      allow_read_products = Sighrax.allow_read_products
      debug_log("allow read products: #{allow_read_products.count}")
      allow_read_products.each { |product| debug_log("allow read product: #{product.identifier}") }
      value = (allow_read_products & component.products).any?
      debug_log("allow_read_products_intersect_component_products_any? #{value}")
      return true if value

      products = Sighrax.actor_products(actor)
      debug_log("actor products: #{products.count}")
      products.each { |product| debug_log("actor product: #{product.identifier}") }
      value = (products & component.products).any?
      debug_log("actor_products_intersect_component_products_any? #{value}")
      value
    else
      value = Sighrax.ability_can?(actor, :edit, target) && Incognito.allow_ability_can?(actor)
      debug_log("ability_can(:edit)? #{value}")
      return true if value

      value = Sighrax.ability_can?(actor, :read, target) && Incognito.allow_ability_can?(actor)
      debug_log("ability_can(:read)? #{value}")
      value
    end
  end

  protected

    attr_reader :share
end
