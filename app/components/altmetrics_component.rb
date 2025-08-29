# frozen_string_literal: true

class AltmetricsComponent < ViewComponent::Base
  def initialize(purl_version:)
    @purl_version = purl_version
    super()
  end

  attr_reader :purl_version

  delegate :title, :publication_date, :authors, :doi_id, to: :purl_version
end
