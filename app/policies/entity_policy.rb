# frozen_string_literal: true

class EntityPolicy < ResourcePolicy
  def initialize(actor, target)
    super(actor, target)
  end

  def download? # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    value = target.downloadable?
    debug_log("downloadable? #{value}")
    return false unless value

    value = Sighrax.platform_admin?(actor)
    debug_log("platform_admin? #{value}")
    return true if value

    value = Sighrax.ability_can?(actor, :edit, target)
    debug_log("ability_can(:edit)? #{value}")
    return true if value

    value = target.tombstone?
    debug_log("tombstone? #{value}")
    return false if value

    value = target.allow_download?
    debug_log("allow_download? #{value}")
    return false unless value

    value = target.published?
    debug_log("published? #{value}")
    return false unless value

    value = target.instance_of?(Sighrax::Asset)
    debug_log("instance_of?(Sighrax::Asset) #{value}")
    return true if value

    value = target.parent.open_access?
    debug_log("open_access? #{value}")
    return true if value

    value = target.parent.unrestricted?
    debug_log("unrestricted? #{value}")
    return true if value

    value = Sighrax.access?(actor, target.parent)
    debug_log("access? #{value}")
    value
  end
end
