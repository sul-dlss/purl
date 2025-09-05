# frozen_string_literal: true

class CollectionItemsComponent < ViewComponent::Base
  def initialize(version:)
    @version = version
    super()
  end

  attr_reader :version

  delegate :collection_items_link, :collection?, to: :version

  def render?
    collection?
  end
end
