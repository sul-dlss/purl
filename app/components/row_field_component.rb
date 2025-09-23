# frozen_string_literal: true

class RowFieldComponent < ViewComponent::Base
  with_collection_parameter :field

  def initialize(field:, delimiter: nil, label_html_attributes: {}, value_html_attributes: {})
    super()

    @field = field
    @delimiter = delimiter
    @label_html_attributes = label_html_attributes
    @value_html_attributes = value_html_attributes
  end

  attr_reader :field, :delimiter, :label_html_attributes, :value_html_attributes

  def render?
    formatted_values.present?
  end

  # If a delimiter is provided, we join with that. Otherwise we wrap each value in it's own dd tag
  def values
    delimiter ? [safe_join(formatted_values, delimiter)] : formatted_values
  end

  def formatted_values
    @formatted_values ||= field.values.compact_blank.map { |value| auto_link value }
  end

  def label
    field.label&.sub(/:$/, '')
  end
end
