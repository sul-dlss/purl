# frozen_string_literal: true

class BibliographicComponent < ViewComponent::Base
  def initialize(version:)
    @version = version
    super()
  end

  attr_reader :version

  delegate :cocina_display, :mods, to: :version
  delegate :general_note_display_data, :identifier_display_data, :access_display_data, to: :cocina_display

  def render?
    general_note_display_data.present? ||
      related_fields.present? ||
      identifier_display_data.present? ||
      access_display_data.present?
  end

  def related_fields
    cocina_display.related_resource_display_data
  end
end
