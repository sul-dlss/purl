# frozen_string_literal: true

class ModsContributorsComponent < ViewComponent::Base
  def initialize(roles_with_contributors:)
    @roles_with_contributors = roles_with_contributors
  end

  def mods_name_field(role)

  end

end
