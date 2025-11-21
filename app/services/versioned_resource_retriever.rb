# frozen_string_literal: true

class VersionedResourceRetriever < ResourceRetriever
  def initialize(druid:, version_id:)
    super(druid:)
    @version_id = version_id
  end

  def public_xml_body
    @public_xml_body ||= open("public.#{version_id}.xml")
  end

  def cocina_body
    @cocina_body ||= open("cocina.#{version_id}.json")
  end

  private

  attr_reader :version_id
end
