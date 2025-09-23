# frozen_string_literal: true

class PublicXml
  def initialize(document)
    @document = document
  end

  attr_reader :document

  def mods
    @mods ||= document.xpath('//mods:mods', 'mods' => 'http://www.loc.gov/mods/v3').first
  end
end
