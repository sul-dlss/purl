module Metadata
  class PublicationDate
    def self.call(mods_ng_document)
      date_element = mods_ng_document.root&.at_xpath('mods:originInfo[@eventType="publication" ' \
      'or @eventType="Publication" or @eventType="PUBLICATION"]/mods:dateIssued', mods: MODS_NS)
      date_element ||= mods_ng_document.root&.at_xpath('mods:originInfo/mods:dateIssued', mods: MODS_NS)
      return unless (matcher = date_element&.text&.match(/(\d{4})/))

      matcher[1]
    end
  end
end
