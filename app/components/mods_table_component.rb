# frozen_string_literal: true

class ModsTableComponent < ViewComponent::Base
  def initialize(fields:, label_id:)
    @fields = fields
    @label_id = label_id
    super()
  end

  attr_reader :fields, :label_id
end
