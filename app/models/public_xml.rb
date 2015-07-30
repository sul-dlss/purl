class PublicXml
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def rights_metadata
    document.at_xpath('/publicObject/rightsMetadata')
  end

  def content_metadata
    document.at_xpath('/publicObject/contentMetadata')
  end
end
