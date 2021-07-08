require 'dor/rights_auth'

class RightsMetadata
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def rights_auth
    @rights_auth ||= Dor::RightsAuth.parse(document.to_s)
  end

  delegate :stanford_only_rights_for_file, :world_rights_for_file, :stanford_only_unrestricted_file?,
           :restricted_by_location?, :world_downloadable_file?, :stanford_only_downloadable_file?,
           :cdl_rights_for_file, :controlled_digital_lending?, to: :rights_auth

  def use_and_reproduction_statement
    document.at_xpath('use/human[@type="useAndReproduction"]').try(:text)
  end

  def copyright_statement
    document.at_xpath('copyright/human').try(:text)
  end

  # Try each way, from most prefered to least preferred to get the license
  def license_url
    license_url_from_node || url_from_attribute || url_from_code
  end

  private

  # This is the most modern way of determining what license to use.
  def license_url_from_node
    document.at_xpath('use/license').try(:text).presence
  end

  # This is a slightly older way, but it can differentiate between CC 3.0 and 4.0 licenses
  def url_from_attribute
    return unless machine_node

    machine_node['uri'].presence
  end

  # This is the most legacy and least preferred way, because it only handles out of data license versions
  def url_from_code
    type, code = machine_readable_license
    return unless type && code.present?

    case type.to_s
    when 'creativeCommons'
      if code == 'pdm'
        'https://creativecommons.org/publicdomain/mark/1.0/'
      else
        "https://creativecommons.org/licenses/#{code}/3.0/legalcode"
      end
    when 'openDataCommons'
      case code
      when 'odc-pddl', 'pddl'
        'https://opendatacommons.org/licenses/pddl/1-0/'
      when 'odc-by'
        'https://opendatacommons.org/licenses/by/1-0/'
      when 'odc-odbl'
        'https://opendatacommons.org/licenses/odbl/1-0/'
      end
    end
  end

  def machine_readable_license
    [machine_node.attribute('type'), machine_node.text] if machine_node
  end

  def machine_node
    @machine_node ||= document.at_xpath('use/machine[@type="openDataCommons" or @type="creativeCommons"]')
  end
end
