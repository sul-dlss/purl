class RelatedResourceComponent < ViewComponent::Base
  def initialize(related_resource:)
    @resource = related_resource
    super()
  end

  attr_reader :resource

  delegate :main_title, to: :resource

  def url
    resource.cocina_doc.dig('description', 'access', 'url', 0, 'value')
  end
end
