class Iiif3MetadataWriter
  # @param [Array] dc_nodes Dublin Core xml nodes
  # @param [Array<String>] published_dates the dates of publication
  def initialize(dc_nodes:, published_dates:, url:)
    @dc_nodes = dc_nodes
    @published_dates = published_dates
    @url = url
  end

  attr_reader :dc_nodes, :published_dates, :url

  # @return [Array<Hash>] the IIIF v3 metadata structure
  def write
    [available_online] + dc_metadata + published
  end

  private

  def dc_metadata # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    nodes_by_name = dc_nodes.group_by(&:name)
    nodes_by_name['relation']&.reject! { it['type'] == 'url' }
    if nodes_by_name['description']
      nodes_with_display_label, description = nodes_by_name['description'].partition { it['displayLabel'] || it['type'] }
      nodes_by_name['description'] = description
      nodes_by_name.merge!(nodes_with_display_label.group_by { it['displayLabel'] || it['type'] })
    end
    nodes_by_name.map { |key, values| iiif_key_value(key.upcase_first, values.map(&:text)) }
  end

  def published
    published_dates.map { |text| iiif_key_value('PublishDate', [text]) }
  end

  def available_online
    iiif_key_value('Available Online', ["<a href='#{url}'>#{url}</a>"])
  end

  def iiif_key_value(label, values)
    { 'label' => { en: [label] }, 'value' => { en: values.compact_blank } }
  end
end
