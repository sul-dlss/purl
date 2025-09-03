# frozen_string_literal: true

class ShowComponent < ViewComponent::Base
  def initialize(version:, purl:)
    @version = version
    @purl = purl
    super()
  end

  attr_reader :version, :purl

  delegate :display_title, :withdrawn?, :embeddable?, :mods, to: :version
end
