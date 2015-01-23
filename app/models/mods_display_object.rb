class ModsDisplayObject
  include ModsDisplay::ModelExtension
  require 'stanford-mods'

  def initialize xml
    @xml=xml
  end

  def xml
    @xml
  end

  def modsxml
    @xml
  end

  mods_xml_source do |obj|
      obj.xml
  end
end