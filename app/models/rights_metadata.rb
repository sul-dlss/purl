require 'dor/rights_auth'

class RightsMetadata
  attr_reader :document
  def initialize(document)
    @document = document
  end

  def rights_auth
    @rights_auth ||= Dor::RightsAuth.parse(document.to_s)
  end

  delegate :stanford_only_rights_for_file, :world_rights_for_file, :stanford_only_unrestricted_file?, to: :rights_auth

  def use_and_reproduction_statement
    document.at_xpath('use/human[@type="useAndReproduction"]/text()').to_s
  end

  def copyright_statement
    document.at_xpath('copyright/human/text()').to_s
  end

  def machine_readable_license
    el = document.at_xpath('use/machine[@type="openDataCommons" or @type="creativeCommons"]')

    [el.attribute('type'), el.text] if el
  end

  def license_statement
    document.at_xpath('use/human[@type="openDataCommons" or @type="creativeCommons"]/text()').to_s
  end
end
