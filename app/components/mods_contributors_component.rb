# frozen_string_literal: true

class ModsContributorsComponent < ViewComponent::Base
  def initialize(document:)
    @document = document
    super()
  end

  attr_reader :document
end
