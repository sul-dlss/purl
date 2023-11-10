# frozen_string_literal: true

class ModsDefinitionListComponent < ViewComponent::Base
  def initialize(fields:, hide_label: false)
    @fields = fields
    @hide_label = hide_label
    super()
  end

  attr_reader :fields, :hide_label

  def label_html_attributes
    return {} unless hide_label

    { class: 'visually-hidden' }
  end
end
