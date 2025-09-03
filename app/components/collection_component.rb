# frozen_string_literal: true

class CollectionComponent < ViewComponent::Base
  def initialize(version:)
    @version = version
    super()
  end

  def collections
    @collections ||= @version.containing_purl_collections
  end

  def render?
    collections.present?
  end
end
