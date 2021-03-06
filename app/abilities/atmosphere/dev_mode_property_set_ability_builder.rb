#
# Dev mode property set abilities.
#
module Atmosphere
  class DevModePropertySetAbilityBuilder < AbilityBuilder
    def add_developer_abilities!
      can [:read, :update], DevModePropertySet,
          appliance: { appliance_set: { user_id: user.id } }
    end
  end
end