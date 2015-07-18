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
      return true if id =~ DRUID_REGEX
      false
    end
  end
end
