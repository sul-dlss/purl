# frozen_string_literal: true

class Iiif3MetadataWriter
  # @param [Hash<Symbol,Object>] cocina_descriptive
  # @param [String] collection_title
  # @param [String] published_date the date of publication
  def initialize(cocina_descriptive:, collection_title:, published_date:, cocina_display:)
    @cocina_descriptive = cocina_descriptive
    @collection_title = collection_title
    @published_date = published_date
    @cocina_display = cocina_display
  end

  attr_reader :cocina_descriptive, :collection_title, :published_date, :cocina_display

  # @return [Array<Hash>] the IIIF v3 metadata structure
  def write # rubocop:disable Metrics/AbcSize
    available_online + titles + contributors + contacts + types + format + language +
      notes + subjects + coverage + dates + identifiers + publisher + collection + publication
  end

  private

  def publication
    [iiif_key_value('PublishDate', [published_date])]
  end

  def publisher
    publishers = cocina_display.publisher_contributors
    publishers.present? ? [iiif_key_value('Publisher', publishers.map(&:display_name))] : []
  end

  def titles
    titles = [cocina_display.display_title] + cocina_display.additional_titles
    [iiif_key_value('Title', titles)]
  end

  def collection
    collection_title.present? ? [iiif_key_value('Relation', [collection_title])] : []
  end

  def contributors
    creators = cocina_display.contributors.select(&:author?)&.map { |auth| auth.display_name(with_date: true) }
    contributors = cocina_display.contributors.reject(&:author?)&.map { |auth| contributor_name(auth) }

    result = creators.present? ? [iiif_key_value('Creator', creators)] : []
    result += [iiif_key_value('Contributor', contributors)] if contributors.present?
    result
  end

  def contributor_name(contributor)
    display_name = contributor.display_name(with_date: true)
    return display_name unless contributor.role?

    "#{display_name} (#{contributor.display_role})"
  end

  # TODO: accessContact not in cocina_display yet
  def contacts
    access = cocina_descriptive['access']
    return [] unless access

    contacts = access.fetch('accessContact').select { it['type'] == 'email' }.pluck('value')
    return [] if contacts.empty?

    [iiif_key_value('Contact', contacts)]
  end

  def types
    [iiif_key_value('Type', cocina_display.genres.presence || resource_types)]
  end

  def format
    vals = cocina_display.extents
    vals.present? ? [iiif_key_value('Format', vals)] : []
  end

  def language
    vals = cocina_display.languages.map(&:to_s)
    vals.present? ? [iiif_key_value('Language', vals)] : []
  end

  # TODO: can't use resource_type_values in cocina_display because it doesn't account for
  # subtypes, which breaks spec/model/iiif3_metadata_writer_spec.rb:249
  def resource_types
    resource_types = Array(cocina_descriptive['form']).filter { it['type'] == 'resource type' }
    resource_types.flat_map { structured_values(it) }.uniq(&:downcase)
  end

  # TODO: add notes to cocina_display
  def notes
    extract_notes.map { |k, v| iiif_key_value(k, v) }
  end

  def extract_notes
    values = {}
    Array(cocina_descriptive['note']).each do |note|
      key = note['displayLabel'] || note['type']&.capitalize || 'Description'
      values[key] ||= []
      values[key] += structured_values(note)
    end
    values
  end

  # This needs to be fixed on cocina_display
  # right not structuredValues aren't getting added to cocina_display.subject_topics or cocina_display.subject_genres
  # this breaks spec/model/iiif3_metadata_writer_spec.rb:514
  def subjects
    vals = Array(cocina_descriptive['subject']).filter_map do |subject|
      structured_values(subject).join(' -- ') if structured_values(subject, 'type').intersect?(%w[topic genre])
    end

    vals.present? ? [iiif_key_value('Subject', vals)] : []
  end

  # TODO: add map scale to cocina_display
  def coverage
    coverage_fields = map_coverage_fields.values.flatten
    coverage_fields.present? ? [iiif_key_value('Coverage', coverage_fields)] : []
  end

  def map_coverage_fields
    coverage_fields = Array(cocina_descriptive['form']) + Array(cocina_descriptive['subject'])
    map_fields = { 'map scale' => [], 'map coordinates' => [] }
    coverage_fields.each do |field|
      map_fields[field['type']] << field['value'] if map_fields.key?(field['type'])
    end
    map_fields
  end

  def dates
    vals = cocina_display.event_dates.map(&:decoded_value)

    vals.present? ? [iiif_key_value('Date', vals)] : []
  end

  # TODO: add other identifiers to cocina_display
  def identifiers
    ids = Array(cocina_descriptive['identifier']).map { |id| format_id(id) }
    ids.push url
    ids.push "doi: #{cocina_display.doi_url}" if cocina_display.doi

    ids.present? ? [iiif_key_value('Identifier', ids)] : []
  end

  def format_id(id)
    source = id.dig('source', 'code')
    return id['value'] unless source && source != 'local'

    "#{source}: #{id['value']}"
  end

  def available_online
    [iiif_key_value('Available Online', ["<a href='#{url}'>#{url}</a>"])]
  end

  # TODO: add purl url to cocina_display
  def url
    @url ||= cocina_descriptive['purl']
  end

  def iiif_key_value(label, values)
    { 'label' => { en: [label] }, 'value' => { en: values.compact_blank } }
  end

  def date_structured_values(field)
    return [structured_values(field).join('-')] if field['structuredValue'].presence && field['structuredValue'].first['type'] == 'start'

    structured_values(field)
  end

  def structured_values(field, field_key = 'value')
    # zf119tw4418 has a structuredValue which has 4 items, the first one is a structuredValue
    if field['structuredValue'].presence
      field['structuredValue'].flat_map do |struct_val|
        struct_val['structuredValue'].present? ? struct_val['structuredValue'].pluck(field_key).join(', ') : struct_val[field_key]
      end
    else
      [field[field_key]]
    end
  end
end
