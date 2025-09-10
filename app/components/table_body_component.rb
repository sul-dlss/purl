# frozen_string_literal: true

class TableBodyComponent < ViewComponent::Base
  renders_many :values

  def initialize(label:)
    super()
    @label = label
  end

  attr_reader :label
end
