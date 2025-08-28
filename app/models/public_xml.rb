# frozen_string_literal: true

class PublicXml
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def title
    @title ||= document.root.at_xpath('oai_dc:dc/dc:title', oai_dc: 'http://www.openarchives.org/OAI/2.0/oai_dc/', dc: 'http://purl.org/dc/elements/1.1/')&.text
  end

  def content_metadata
    document.root.at_xpath('contentMetadata')
  end

  def thumb
    document.root.at_xpath('thumb')&.text
  end

  def mods
    @mods ||= document.xpath('//mods:mods', 'mods' => 'http://www.loc.gov/mods/v3').first
  end
end
