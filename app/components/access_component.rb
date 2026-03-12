# frozen_string_literal: true

class AccessComponent < ViewComponent::Base
  def initialize(version:)
    @version = version
    super()
  end

  attr_reader :version

  delegate :cocina_display, to: :version

  def field_map
    @field_map ||= [
      cocina_display.use_and_reproduction_display_data,
      cocina_display.copyright_display_data,
      cocina_display.license_display_data
    ].compact_blank
  end

  def render?
    field_map.present?
  end
end
