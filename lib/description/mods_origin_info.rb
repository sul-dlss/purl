class Description
  class ModsOriginInfo
    def initialize(mods_ng:)
      @mods_ng = mods_ng
    end

    # Year from publication originInfo with a dateIssued
    # Otherwise, year from first originInfo with a dateIssued
    # @return [String,nil] four-digit year if present
    def publication_year
      @publication_year ||= begin
        date_element = mods_ng.root&.at_xpath('mods:originInfo[@eventType="publication" ' \
        'or @eventType="Publication" or @eventType="PUBLICATION"]/mods:dateIssued', mods: MODS_NS)
        date_element ||= mods_ng.root&.at_xpath('mods:originInfo/mods:dateIssued', mods: MODS_NS)
        if (matcher = date_element&.text&.match(/(\d{4})/))
          matcher[1]
        end
      end
    end

    private

    attr_reader :mods_ng
  end
end
