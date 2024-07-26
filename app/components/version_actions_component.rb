# frozen_string_literal: true

class VersionActionsComponent < ViewComponent::Base
  def initialize(version:, requested_version:, url:)
    @version = version
    @requested_version = requested_version
    @url = url
    super
  end

  attr_reader :version, :url

  delegate :withdrawn?, to: :version

  def requested_version?
    @requested_version.version_id == version.version_id
  end
end
