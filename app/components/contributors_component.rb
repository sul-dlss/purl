# frozen_string_literal: true

class ContributorsComponent < ViewComponent::Base
  def initialize(version:)
    @version = version
    super()
  end

  attr_reader :version

  delegate :cocina_display, :mods, to: :version

  def render?
    contributors_by_role.present?
  end

  def contributors_by_role
    @contributors_by_role ||= cocina_display.contributors_by_role
                                            .excluding('publisher')
                                            .transform_keys { it.nil? ? 'Associated with' : it.titleize }
  end

  def label_id
    'section-creators'
  end
end
