# frozen_string_literal: true

class TableComponent < ViewComponent::Base
  def initialize(label_id:)
    @label_id = label_id
    super()
  end

  attr_reader :label_id
end
