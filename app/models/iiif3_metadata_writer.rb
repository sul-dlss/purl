# frozen_string_literal: true

class Iiif3MetadataWriter
  # @param [String] collection_title
  # @param [String] published_date the date of publication
  # @param [CocinaDisplay] cocina_display from gem
  def initialize(collection_title:, published_date:, cocina_display:)
    @collection_title = collection_title
    @published_date = published_date
    @cocina_display = cocina_display
  end

  attr_reader :collection_title, :published_date, :cocina_display

  # @return [Array<Hash>] the IIIF v3 metadata structure
  def write # rubocop:disable Metrics/AbcSize
    available_online + titles + contributors + contacts + types + format + language +
      notes + subjects + coverage + dates + identifiers + publisher + collection + publication
  end

  private

  def formatted_published_date
    published_date.strftime('%Y-%m-%d')
  end

  def publication
    [iiif_key_value('Record published', [formatted_published_date])]
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
    creators = cocina_display.contributors.select(&:author?).map { |auth| auth.display_name(with_date: true) }
    contributors = cocina_display.contributors.filter_map { |contrib| contributor_name(contrib) }

    result = creators.present? ? [iiif_key_value('Creator', creators)] : []
    result += [iiif_key_value('Contributor', contributors)] if contributors.present?
    result
  end

  def contributor_name(contributor)
    return if contributor.author? || contributor.publisher?

    display_name = contributor.display_name(with_date: true)
    return display_name unless contributor.role?

    "#{display_name} (#{contributor.roles.map(&:to_s).join(', ')})"
  end

  # TODO: accessContact not in cocina_display yet
  def contacts
    contacts = cocina_display.contact_email_display_data.flat_map(&:values)
    contacts.present? ? [iiif_key_value('Contact', contacts)] : []
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

  def resource_types
    cocina_display.send(:resource_type_values)
  end

  # TODO: add notes to cocina_display
  def notes
    extract_notes.map { |k, v| iiif_key_value(k, v) }
  end

  def extract_notes
    values = {}
    cocina_display.notes.each do |note|
      key = note.display_label || note.type&.capitalize || 'Description'
      values[key] ||= []
      values[key] += [note.to_s]
    end
    values
  end

  def subjects
    subjects = cocina_display.subject_display_data.flat_map { |sub| sub.values if sub.label == 'Subject' }

    subjects.present? ? [iiif_key_value('Subject', subjects)] : []
  end

  def coverage
    coverage_fields = cocina_display.map_display_data.flat_map { |mdd| mdd.values if mdd.label == 'Map data' }

    coverage_fields.present? ? [iiif_key_value('Coverage', coverage_fields)] : []
  end

  def dates
    vals = cocina_display.event_dates.map(&:decoded_value)

    vals.present? ? [iiif_key_value('Date', vals)] : []
  end

  def identifiers
    ids = cocina_display.identifier_display_data.flat_map do |id|
      id.values.map { |i| id.label == 'Identifier' ? i : "#{id.label}: #{i}" }
    end
    ids.push url
    ids.push "doi: #{cocina_display.doi_url}" if cocina_display.doi

    ids.present? ? [iiif_key_value('Identifier', ids)] : []
  end

  def available_online
    [iiif_key_value('Available Online', ["<a href='#{url}'>#{url}</a>"])]
  end

  def url
    @url ||= cocina_display.purl_url
  end

  def iiif_key_value(label, values)
    { 'label' => { 'en' => [label] }, 'value' => { 'en' => values.compact_blank } }
  end
end
