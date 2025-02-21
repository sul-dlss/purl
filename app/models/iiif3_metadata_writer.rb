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

  def dc_metadata
    dc_nodes.group_by(&:name).map { |key, values| iiif_key_value(key.upcase_first, values.map(&:text)) }
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
