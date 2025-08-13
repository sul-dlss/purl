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
           :world_downloadable?, :stanford_only_downloadable?,
           to: :rights_auth

  def use_and_reproduction_statement
    document.at_xpath('use/human[@type="useAndReproduction"]').try(:text)
  end

  def copyright_statement
    document.at_xpath('copyright/human').try(:text)
  end
end
