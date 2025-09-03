# frozen_string_literal: true

class ModsContributorsComponent < ViewComponent::Base
  def initialize(mods:)
    @mods = mods
    super()
  end

  attr_reader :mods
end
