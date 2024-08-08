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

  def updated_at(version)
    l(version.updated_at.to_date, format: :short) if version.updated_at
  end

  def url(version)
    versioned_purl_url(id: purl.druid, version: "v#{version.version_id}")
  end

  def versions
    @purl.versions.sort_by(&:version_id).reverse
  end
end
