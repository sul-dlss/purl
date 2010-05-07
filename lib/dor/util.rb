require "nokogiri"

module Dor

  # constants
  DRUID_REGEX = /^[a-z]{2}\d{3}[a-z]{2}\d{4}$/i

  class Util

    #
    # validates the id to be of the format 'xxyyyxxyyyy'
    #
    #     where 'x' is an alphabetic character
    #     where 'y' is a numeric character
    #
    def self.validate_druid(id)
      if(id =~ DRUID_REGEX)
        return true
      end
      return false
    end

    # determines whether the given id exists in the repository
    def self.exists_resource(id)
      false
    end

    def self.pretty_print_xml(xml)
      d = Nokogiri::XML.parse(xml)
      d.to_xml
    end

  end

end
