# frozen_string_literal: true

class EmbedComponent < ViewComponent::Base
  def initialize(version:)
    @version = version
    super()
  end

  attr_reader :version

  def render?
    version.embeddable?
  end
end
