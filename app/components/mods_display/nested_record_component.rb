# frozen_string_literal: true

module ModsDisplay
  class NestedRecordComponent < ViewComponent::Base
    with_collection_parameter :record

    def initialize(record:, html_attributes: {})
      super

      @record = record
      @html_attributes = html_attributes
    end

    attr_reader :record, :html_attributes

    def fields
      if linked_title?
        ModsDisplay::RecordComponent::DEFAULT_FIELDS - [:subTitle] - [:location]
      elsif reference?
        ModsDisplay::RecordComponent::DEFAULT_FIELDS - [:subTitle] - [:note]
      else
        [:title] + ModsDisplay::RecordComponent::DEFAULT_FIELDS - [:subTitle]
      end
    end

    def linked_title?
      location.present? && title?
    end

    def location
      @location ||= record.xml.root.xpath('mods:location/mods:url', mods: PurlVersion::MODS_NS).first&.content
    end

    def reference?
      @reference ||= !collection? && record.xml.root.get_attribute('type') == 'isReferencedBy'
    end

    def collection?
      @collection ||= record.xml.root.xpath('mods:typeOfResource', mods: PurlVersion::MODS_NS).first&.get_attribute('collection') == 'yes'
    end

    private

    def title?
      record.xml.root.xpath('mods:titleInfo', mods: PurlVersion::MODS_NS).present?
    end
  end
end
