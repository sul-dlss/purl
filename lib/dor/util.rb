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
    #
    def self.exists_resource(id)

      # TODO : dougkim
      # make sure that the requested resource is an etd
      # rels_ext_md = DorService.new.get_datastream_contents(id,'RELS-EXT')
      # puts rels_ext_md
      # doc = Nokogiri::XML(rels_ext_md)
      # fedora_content_model = doc.root.xpath("//conformsTo[@rdf:resource]").collect(&:text)
      # puts "Content Model : #{fedora_content_model}"
      
      # resource ready for delivery must have a 'shelve' workflow status of 'released'

      # for now, pretend as if the resource always exists
      true
    end

  end

end
