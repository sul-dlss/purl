# frozen_string_literal: true

class VersionRowComponent < ViewComponent::Base
  with_collection_parameter :version

  def initialize(version:, requested_version:)
    @version = version
    @requested_version = requested_version
    super
  end

  attr_reader :version, :requested_version

  def updated_at
    l(version.updated_at.to_date, format: :short) if version.updated_at
  end
end
