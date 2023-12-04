module Purl
  class RelatedItemValueRenderer < ModsDisplay::NestedRelatedItem::ValueRenderer
    def render
      body_presence(mods_display_html.body(html_attributes: { class: 'mods_display_related_item' }, component: ModsDisplay::NestedRecordComponent))
    end
  end
end
