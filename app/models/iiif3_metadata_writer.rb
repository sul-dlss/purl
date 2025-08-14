class Iiif3MetadataWriter
  # @param [Hash<Symbol,Object>] cocina_descriptive
  # @param [String] collection_title
  # @param [String] published_date the date of publication
  def initialize(cocina_descriptive:, collection_title:, published_date:, doi:)
    @cocina_descriptive = cocina_descriptive
    @collection_title = collection_title
    @published_date = published_date
    @doi = doi
  end

  attr_reader :cocina_descriptive, :collection_title, :published_date, :doi

  # @return [Array<Hash>] the IIIF v3 metadata structure
  def write # rubocop:disable Metrics/AbcSize
    available_online + titles + contributors + contacts + types + format + language +
      notes + subjects + coverage + dates + identifiers + collection + publication
  end

  private

  def publication
    [iiif_key_value('PublishDate', [published_date])]
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
    access_contact = cocina_descriptive.dig('access', 'accessContact')
    return [] unless access_contact

    [iiif_key_value('Contact', access_contact.select { it['type'] == 'email' }.pluck('value'))]
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
      it['value'] if it['type'] == 'topic'
    end
    vals.present? ? [iiif_key_value('Subject', vals)] : []
  end

  def coverage
    vals = Array(cocina_descriptive['subject']).filter_map do
      it['value'] if it['type'] == 'map coordinates'
    end
    vals.present? ? [iiif_key_value('Coverage', vals)] : []
  end

  def dates
    vals = Array(cocina_descriptive['event']).flat_map do
      it['date'].map { it['value'] }
    end

    vals.present? ? [iiif_key_value('Date', vals)] : []
  end

  def identifiers
    ids = Array(cocina_descriptive['identifier']).pluck('value')
    ids.push url
    ids.push "doi: https://doi.org/#{doi}" if doi

    ids.present? ? [iiif_key_value('Identifier', ids)] : []
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

  def structured_values(field)
    field['structuredValue'].presence ? field['structuredValue'].pluck('value') : [field['value']]
  end
end
