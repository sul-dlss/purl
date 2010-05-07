require "dor/dor_service"
require 'nokogiri'

module PurlHelper

  def self.extract_metadata(id)
    metadata = Metadata.new
    metadata = extract_dc_metadata(id, metadata)
    metadata = extract_identity_metadata(id, metadata)
    metadata = extract_rights_metadata(id, metadata)
    metadata = extract_content_metadata(id, metadata)
    metadata
  end

  private

  def self.retrieve_document(id, datastream)
    datastream = Dor::DorService.new.get_datastream_contents(id, datastream)
    doc = Nokogiri::XML(datastream)
  end

  # extract the relevant fields from the DC datastream
  def self.extract_dc_metadata(id, metadata)
    doc = retrieve_document(id, 'DC')
    # titles
    elements = doc.root.xpath("//dc:title").collect(&:text)
    titles = elements.map {|e| e.to_s}
    metadata.instance_variable_set(:@titles, titles)
    # creators
    elements = doc.root.xpath("//dc:creator").collect(&:text)
    creators = elements.map {|e| e.to_s}
    metadata.instance_variable_set(:@creators, creators)
    return metadata
  end

  # extract the relevant fields from the identityMetadata datastream
  def self.extract_identity_metadata(id, metadata)
    doc = retrieve_document(id, 'identityMetadata')
    objectType = doc.root.xpath("//objectType").collect(&:text)   # object type
    tags = doc.root.xpath("//tag").collect(&:text)                # tags
    metadata.instance_variable_set(:@objectType, objectType)
    metadata.instance_variable_set(:@tags, tags)
    return metadata
  end

  # extract the relevant fields from the rightsMetadata datastream
  def self.extract_rights_metadata(id, metadata)
    doc = retrieve_document(id, 'rightsMetadata')
    embargo = doc.root.xpath("//embargo").collect(&:text)         # embargo
    metadata.instance_variable_set(:@embargo, embargo)
    return metadata
  end

  # extract the relevant fields from the contentMetadata datastream
  def self.extract_content_metadata(id, metadata)
    doc = retrieve_document(id, 'contentMetadata')
    page_tags = doc.root.xpath("//attr").collect(&:text)          # page tags
    metadata.instance_variable_set(:@page_tags, page_tags)
    return metadata
  end

end
