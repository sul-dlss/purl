# frozen_string_literal: true

class ModsContributorsComponent < ViewComponent::Base
  def initialize(mods:)
    @mods = mods
    super()
  end

  attr_reader :mods

  def names
    @names ||= mods.name
  end

  def render?
    names.present?
  end

  def label_id
    'section-creators'
  end
end
