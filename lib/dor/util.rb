require "nokogiri"

module Dor

  # constants
  DRUID_REGEX = /^[a-z]{2}\d{3}[a-z]{2}\d{4}$/i

  class Util

    #
    # This method validates the given id to be of the following format:
    #
    #   'xxyyyxxyyyy'
    #
    #      where 'x' is an alphabetic character
    #      where 'y' is a numeric character
    #
    def self.validate_druid(id)
      if(id =~ DRUID_REGEX)
        return true
      end
      return false
    end

    #
    # This method reverses the first and last name of the given comma-delimited string
    #
    def self.reverse_name(name_str)
      if(name_str =~ /,/)
        name_str =~ /([^,\r\n]*),\s*(.*)/
        last = $1
        first = $2
        name_str = "#{first} #{last}"
      end
      name_str
    end
  
    #
    # This method determines whether the resource for the given id is ready for delivery
    # based on the 'shelve' workflow status
    #
    def self.is_shelved?(id)
      shelve_status = WorkflowService.get_workflow_status('dor', 'druid:' + id,'etdAccessionWF','shelve')
      if( "#{shelve_status}".eql? "completed" )
        return true
      end
      return false
    end

  end

end
