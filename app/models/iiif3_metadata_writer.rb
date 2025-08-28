# frozen_string_literal: true

class Iiif3MetadataWriter
  # @param [Hash<Symbol,Object>] cocina_descriptive
  # @param [String] collection_title
  # @param [String] published_date the date of publication
  def initialize(cocina_descriptive:, collection_title:, published_date:, doi:, cocina_display:)
    @cocina_descriptive = cocina_descriptive
    @collection_title = collection_title
    @published_date = published_date
    @cocina_display = cocina_display
    @doi = doi
  end

  attr_reader :cocina_descriptive, :collection_title, :published_date, :doi, :cocina_display

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
    [iiif_key_value('Title', Array(cocina_descriptive['title']).flat_map do
      Array(it['structuredValue']).map { it['value'] }.presence || it['value']
    end)]
  end

  def collection
    collection_title.present? ? [iiif_key_value('Relation', [collection_title])] : []
  end

  def contributors
    creator = nil
    contributor_list = []
    Array(cocina_descriptive['contributor']).each do
      next unless it['type'] == 'person'

      name = contributor_name(it.dig('name', 0))
      role = it.dig('role', 0, 'value')
      if role == 'creator'
        creator = name
      else
        contributor_list += [role ? "#{name} (#{role})" : name]
      end
    end

    result = contributor_list.present? ? [iiif_key_value('Contributor', contributor_list)] : []
    result += [iiif_key_value('Creator', [creator])] if creator
    result
  end

  def contributor_name(contributor)
    structured_name = contributor['structuredValue'].presence
    return contributor['value'] unless structured_name

    single_name = structured_name.find { it['type'] == 'name' }
    life_date = structured_name.find { it['type'] == 'life dates' }
    return name_with_dates(single_name['value'], life_date) if single_name

    forename = structured_name.find { it['type'] == 'forename' }['value']
    surname = structured_name.find { it['type'] == 'surname' }['value']
    name_with_dates("#{surname}, #{forename}", life_date)
  end

  def name_with_dates(name, date_struct)
    return name if date_struct.blank?

    "#{name}, #{date_struct['value']}"
  end

  def contacts
    access = cocina_descriptive['access']
    return [] unless access

    contacts = access.fetch('accessContact').select { it['type'] == 'email' }.pluck('value')
    return [] if contacts.empty?

    [iiif_key_value('Contact', contacts)]
  end

  def types
    [iiif_key_value('Type', genre.presence || resource_types)]
  end

  def format
    vals = filtered_form('extent').pluck('value')
    vals.present? ? [iiif_key_value('Format', vals)] : []
  end

  def language
    vals = Array(cocina_descriptive['language']).map { it['value'] || it['code'] }
    vals.present? ? [iiif_key_value('Language', vals)] : []
  end

  def genre
    filtered_form('genre').pluck('value')
  end

  def resource_types
    filtered_form('resource type').flat_map { structured_values(it) }.uniq(&:downcase)
  end

  def filtered_form(type)
    Array(cocina_descriptive['form']).filter { it['type'] == type }
  end

  def notes
    extract_notes.map { |k, v| iiif_key_value(k, v) }
  end

  def extract_notes
    values = {}
    Array(cocina_descriptive['note']).each do
      key = it['displayLabel'] || it['type']&.capitalize || 'Description'
      values[key] ||= []
      values[key] += structured_values(it)
    end
    values
  end

  def subjects
    vals = Array(cocina_descriptive['subject']).filter_map do
      structured_values(it).join(' -- ') if structured_values(it, 'type').intersect?(%w[topic genre])
    end
    vals.present? ? [iiif_key_value('Subject', vals)] : []
  end

  def coverage
    coverage_fields = map_coverage_fields.values.flatten
    coverage_fields.present? ? [iiif_key_value('Coverage', coverage_fields)] : []
  end

  def map_coverage_fields
    coverage_fields = Array(cocina_descriptive['form']) + Array(cocina_descriptive['subject'])
    map_fields = { 'map scale' => [], 'map coordinates' => [] }
    coverage_fields.each do
      map_fields[it['type']] << it['value'] if map_fields.key?(it['type'])
    end
    map_fields
  end

  def dates
    vals = Array(cocina_descriptive['event']).flat_map do
      it['date'].flat_map { date_structured_values(it) }
    end

    vals.present? ? [iiif_key_value('Date', vals)] : []
  end

  def identifiers
    ids = Array(cocina_descriptive['identifier']).map { |id| format_id(id) }
    ids.push url
    ids.push "doi: https://doi.org/#{doi}" if doi

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
