# frozen_string_literal: true

class RowFieldComponent < ViewComponent::Base
  with_collection_parameter :field

  def initialize(field:, delimiter: nil, label_html_attributes: {}, value_html_attributes: {}, value_transformer: nil)
    super()

    @field = field
    @delimiter = delimiter
    @value_transformer = value_transformer
    @label_html_attributes = label_html_attributes
    @value_html_attributes = value_html_attributes
  end

  attr_reader :field, :delimiter, :label_html_attributes, :value_html_attributes

  def render?
    field.values.any?(&:present?)
  end

  def format_value(value)
    if @value_transformer
      @value_transformer.call(value)
    else
      helpers.format_mods_html(value, field:)
    end
  end

  def values
    if delimiter
      [safe_join(field.values.compact_blank.map { |value| format_value(value) }, delimiter)]
    else
      field.values.compact_blank.map { |value| format_value(value) }
    end
  end

  def label
    field.label&.sub(/:$/, '')
  end
end
