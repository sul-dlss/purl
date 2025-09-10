# frozen_string_literal: true

class BibliographicComponent < ViewComponent::Base
  def initialize(version:)
    @version = version
    super()
  end

  attr_reader :version

  delegate :cocina_display, :mods, to: :version
  delegate :identifier, :location, to: :mods
  delegate :general_note_display_data, to: :cocina_display

  def render?
    general_note_display_data.present? ||
      middle_fields.present? ||
      identifier.present? ||
      location.present?
  end

  def middle_fields
    @middle_fields ||= mods.relatedItem(value_renderer: Purl::RelatedItemValueRenderer) +
                       mods.nestedRelatedItem(value_renderer: Purl::RelatedItemValueRenderer)
  end
end
