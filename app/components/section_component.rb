# frozen_string_literal: true

class SectionComponent < ViewComponent::Base
  def initialize(label:, label_id: nil)
    @label = label
    @label_id = label_id
    super()
  end

  attr_reader :label

  # Generate a URL-friendly ID from the label if one was not provided
  def label_id
    @label_id || label.parameterize
  end
end
