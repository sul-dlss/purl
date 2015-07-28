module Dor
  # constants
  DRUID_REGEX = /^([a-z]{2})(\d{3})([a-z]{2})(\d{4})$/i

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
      id =~ DRUID_REGEX
    end

    # Returns the pair tree directory for a given, valid druid
    #
    def self.create_pair_tree(pid)
      match = pid.match(DRUID_REGEX)

      File.join(match[1], match[2], match[3], match[4]) if match
    end
  end
end
