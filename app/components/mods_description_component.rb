# frozen_string_literal: true

class ModsDescriptionComponent < ViewComponent::Base
  def initialize(document:)
    @document = document
    super()
  end

  attr_reader :document

  def label_id
    'section-description'
  end

  COMMA = ', '
  SEMICOLON = '; '
  DL = nil

  # Ordered list of fields and delimiters to display
  def field_map # rubocop:disable Metrics/AbcSize
    @field_map ||= [
      [document.mods.mods_field(:title).fields.select { |x| x.label =~ /^Alternative Title/i }, DL],
      [document.mods.mods_field(:title).fields.reject { |x| x.label =~ /^(Alternative )?Title/i }, COMMA],
      [document.mods.resourceType, COMMA],
      [document.mods.form, SEMICOLON],
      [document.mods.extent, COMMA],
      [document.mods.imprint, COMMA],
      [document.mods.language, SEMICOLON],
      [document.mods.description, COMMA],
      [document.mods.cartographics, COMMA]
    ].select { |field, _| field.present? }
  end

  def render?
    field_map.present?
  end
end
