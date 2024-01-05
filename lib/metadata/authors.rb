module Metadata
  class Authors
    def self.call(mods_ng_document)
      new(mods_ng_document).call
    end

    def initialize(mods_ng_document)
      @mods_ng_document = mods_ng_document
    end

    def call
      name_elements.map { |name_element| ModsDisplay::NameFormatter.format(name_element) }
    end

    private

    attr_reader :mods_ng_document

    def name_elements
      names_with_author_roles.to_a.presence \
      || names_without_roles.to_a.presence \
      || [first_name_with_any_role].compact.presence \
      || []
    end

    def names_with_author_roles
      mods_ng_document.xpath('mods:name[mods:role/mods:roleTerm[contains(text(), "AUT") ' \
      'or contains(text(), "aut") or contains(text(), "author") or contains(text(), "Author")]]', mods: MODS_NS)
    end

    def names_without_roles
      mods_ng_document.xpath('mods:name[count(mods:role) = 0]', mods: MODS_NS)
    end

    def first_name_with_any_role
      mods_ng_document.at_xpath('mods:name[mods:role]', mods: MODS_NS)
    end
  end
end
