require 'dor/rights_auth'

class RightsMetadata
  attr_reader :document
  def initialize(document)
    @document = document
  end

  def rights_auth
    @rights_auth ||= Dor::RightsAuth.parse(document.to_s)
  end

  delegate :stanford_only_rights_for_file, :world_rights_for_file, :stanford_only_unrestricted_file?, :restricted_by_location?, to: :rights_auth

  def use_and_reproduction_statement
    document.at_xpath('use/human[@type="useAndReproduction"]').try(:text)
  end

  def copyright_statement
    document.at_xpath('copyright/human').try(:text)
  end

  def machine_readable_license
    el = document.at_xpath('use/machine[@type="openDataCommons" or @type="creativeCommons"]')

    [el.attribute('type'), el.text] if el
  end

  def license_statement
    document.at_xpath('use/human[@type="openDataCommons" or @type="creativeCommons"]').try(:text)
  end

  def read_group
    read_group = document.at_xpath('access[@type="read"]/machine/*')

    return unless read_group

    case read_group.name
    when 'group'
      read_group.text
    else
      read_group.name
    end
  end
end
