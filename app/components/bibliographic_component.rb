# frozen_string_literal: true

class BibliographicComponent < ViewComponent::Base
  def initialize(mods:)
    @mods = mods
    super()
  end

  attr_reader :mods

  delegate :identifier, :location, to: :mods

  def render?
    mods.audience.present? ||
      note_fields.present? ||
      middle_fields.present? ||
      identifier.present? ||
      location.present?
  end

  def note_fields
    @note_fields ||= mods.note.reject { |x| x.label =~ /Preferred citation/i }
  end

  def middle_fields
    @middle_fields ||= mods.relatedItem(value_renderer: Purl::RelatedItemValueRenderer) +
                       mods.nestedRelatedItem(value_renderer: Purl::RelatedItemValueRenderer)
  end
end
