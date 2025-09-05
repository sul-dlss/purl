# frozen_string_literal: true

class VersionedResourceRetriever < ResourceRetriever
  def initialize(druid:, version_id:)
    super(druid:)
    @version_id = version_id
  end

  def public_xml_body
    @public_xml_body ||= public_xml_resource.read
  end

  def cocina_body
    @cocina_body ||= cocina_resource.read
  end

  private

  attr_reader :version_id

  def public_xml_resource
    @public_xml_resource ||= File.open(public_xml_path)
  end

  def cocina_resource
    @cocina_resource ||= File.open(cocina_path)
  end

  def public_xml_path
    File.join(druid_path, "public.#{version_id}.xml")
  end

  def cocina_path
    File.join(druid_path, "cocina.#{version_id}.json")
  end
end
