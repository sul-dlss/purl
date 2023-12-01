# frozen_string_literal: true

class TableComponent < ViewComponent::Base
  def initialize(label_id:, with_body: true)
    @label_id = label_id
    @with_body = with_body
    super()
  end

  attr_reader :label_id

  def with_body?
    @with_body
  end
end
