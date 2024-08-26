# frozen_string_literal: true

class BibliographicComponent < ViewComponent::Base
  def initialize(document:)
    @document = document
    super()
  end

  attr_reader :document

  delegate :mods, to: :document
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

  # Adds the "Stanford only" red "S" if this is via the OCLC proxy
  def build_transformer(field)
    ->(value) { format_mods_html(value, field:) + with_stanford_only(value) }
  end

  def with_stanford_only(value)
    return unless value.downcase.include?('https://stanford.idm.oclc.org/login?url=')

    tag.span class: 'stanford-only-text' do
      tag.span 'Stanford only', class: 'visually-hidden'
    end
  end
end
