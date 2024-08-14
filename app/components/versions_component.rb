# frozen_string_literal: true

class VersionsComponent < ViewComponent::Base
  def initialize(purl:, version:)
    @purl = purl
    @version = version
    @label_id = 'versions'
    super
  end

  attr_reader :purl, :label_id

  def embeddable_url
    @embeddable_url ||= helpers.embeddable_url(purl.druid)
  end

  def versions
    @purl.versions.sort_by(&:version_id).reverse
  end
end
