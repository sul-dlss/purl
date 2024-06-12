# frozen_string_literal: true

class TableBodyComponent < ViewComponent::Base
  renders_many :values

  def initialize(field:)
    super

    @field = field
  end

  attr_reader :field

  def render?
    field.values.any?(&:present?)
  end

  def label
    field.label&.delete_suffix(':')
  end
end
