# frozen_string_literal: true

class VersionActionsComponent < ViewComponent::Base
  def initialize(version:, requested_version:, url:)
    @version = version
    @requested_version = requested_version
    @url = url
    super
  end

  attr_reader :version, :url

  delegate :state, to: :version

  def available?
    state == 'available'
  end

  def requested_version?
    @requested_version.version_id == version.version_id
  end
end
