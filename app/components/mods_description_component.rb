# frozen_string_literal: true

class ModsDescriptionComponent < ViewComponent::Base
  def initialize(mods:)
    @mods = mods
    super()
  end

  attr_reader :mods

  def label_id
    'section-description'
  end

  COMMA = ', '
  SEMICOLON = '; '
  DL = nil

  # Ordered list of fields and delimiters to display
  def field_map # rubocop:disable Metrics/AbcSize
    @field_map ||= [
      [mods.mods_field(:title).fields.select { |x| x.label =~ /^Alternative Title/i }, DL],
      [mods.mods_field(:title).fields.reject { |x| x.label =~ /^(Alternative )?Title/i }, COMMA],
      [mods.resourceType, COMMA],
      [mods.form, SEMICOLON],
      [mods.extent, COMMA],
      [mods.place, DL],
      [mods.publisher, COMMA],
      [mods.dateCreated, SEMICOLON],
      [mods.dateCaptured, SEMICOLON],
      [mods.dateValid, SEMICOLON],
      [mods.dateModified, SEMICOLON],
      [mods.dateOther, SEMICOLON],
      [mods.copyrightDate, SEMICOLON],
      [mods.dateIssued, SEMICOLON],
      [mods.issuance, COMMA],
      [mods.frequency, COMMA],
      [mods.edition, COMMA],
      [mods.language, SEMICOLON],
      [mods.description, COMMA],
      [mods.cartographics, COMMA]
    ].select { |field, _| field.present? }
  end

  def render?
    field_map.present?
  end
end
