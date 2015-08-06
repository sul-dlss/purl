class PublicXml
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def title
    @title ||= document.root.at_xpath('oai_dc:dc/dc:title/text()', oai_dc: 'http://www.openarchives.org/OAI/2.0/oai_dc/', dc: 'http://purl.org/dc/elements/1.1/').to_s
  end

  def rights_metadata
    document.root.at_xpath('rightsMetadata')
  end

  def content_metadata
    document.root.at_xpath('contentMetadata')
  end
end
