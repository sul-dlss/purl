class ModsDisplayObject
  include ModsDisplay::ModelExtension
  require 'stanford-mods'

  def initialize(xml)
    @xml = xml
  end

  attr_reader :xml

  def modsxml
    @xml
  end

  mods_xml_source(&:xml)
end
