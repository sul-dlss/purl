# frozen_string_literal: true

class PublicXml
  def initialize(public_xml_body)
    @document = Nokogiri::XML(public_xml_body)
  end

  attr_reader :document

  def mods
    @mods ||= document.xpath('//mods:mods', 'mods' => 'http://www.loc.gov/mods/v3').first
  end
end
