class Description
  class ModsFormattedName
    def initialize(mods_ng:)
      @mods_ng = mods_ng
    end

    # Names with author roles.
    # Otherwise, names without roles.
    # Otherwise, first name with any role.
    # Names are formatted as a string with ModsDisplay::NameFormatter.
    # @return [Array<String>] formatted names
    def formatted_names
      @formatted_names ||= name_elements.map { |name_element| ModsDisplay::NameFormatter.format(name_element) }
    end

    private

    attr_reader :mods_ng

    def name_elements
      names_with_author_roles.to_a.presence \
      || names_without_roles.to_a.presence \
      || [first_name_with_any_role].compact.presence \
      || []
    end

    def names_with_author_roles
      mods_ng.root&.xpath('mods:name[mods:role/mods:roleTerm[contains(text(), "AUT") ' \
      'or contains(text(), "aut") or contains(text(), "author") or contains(text(), "Author")]]', mods: MODS_NS)
    end

    def names_without_roles
      mods_ng.root&.xpath('mods:name[count(mods:role) = 0]', mods: MODS_NS)
    end

    def first_name_with_any_role
      mods_ng.root&.at_xpath('mods:name[mods:role]', mods: MODS_NS)
    end
  end
end
