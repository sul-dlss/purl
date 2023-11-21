module Metadata
  # rubocop:disable Metrics/ClassLength
  class SchemaDotOrg
    def self.call(cocina_json)
      new(cocina_json).call
    end

    def self.schema_type?(cocina_json)
      new(cocina_json).schema_type?
    end

    def initialize(cocina_json)
      @cocina_json = cocina_json
    end

    def call
      { "@context": 'http://schema.org',
        "@type": schema_type,
        "name": title_name,
        "description": description }
        .merge(format_specific_fields)
        .compact
    end

    def schema_type?
      dataset? || render_video_metadata?
    end

    private

    def schema_type
      return 'Dataset' if dataset?

      'VideoObject' if render_video_metadata?
    end

    def dataset?
      # has a form with value of dataset and type of genre
      dataset = JsonPath.new("$.description.form[?(@['value'] == 'dataset' && @['type'] == 'genre')]").on(@cocina_json)
      dataset.any?
    end

    def render_video_metadata?
      # Only return video metadata if world-downloadable.
      video = JsonPath.new("$.structural.contains[?(@['type'] == 'https://cocina.sul.stanford.edu/models/resources/video')]").on(@cocina_json)
      video.any? && object_access? && video_access?
    end

    def title_name
      # title.value or concatenated title.structuredValue 1) for title with status "primary" if present 2) for first title
      # required for Datasets and Videos
      titles = JsonPath.new("$.description.title[?(@['status' == 'primary'])].structuredValue[*].value").on(@cocina_json)
      return titles.join(': ') unless titles.empty?

      JsonPath.new('$.description.title[0].value').first(@cocina_json)
    end

    def format_specific_fields
      if dataset?
        return { "identifier": identifier,
                 "isAccessibleForFree": object_access?,
                 "license": license,
                 "url": url,
                 "creator": creators }
      elsif render_video_metadata?
        return { "thumbnailUrl": thumbnail,
                 "uploadDate": upload_date,
                 "embedUrl": embed_url }
      end
      {}
    end

    def description
      # description.note where type=summary or type=abstract, concatenating with \n if multiple
      # required for Datasets
      notes = JsonPath.new("$.description.note[?(@['type'] == 'summary' || @['type'] == 'abstract')].value").on(@cocina_json)
      notes.join('\n') unless notes.empty?
    end

    def identifier
      # identification.doi or identifier.uri including doi.org or identifier.value with type "doi" (case-insensitive), made into URI if identifier only
      doi_id = JsonPath.new('$.identification.doi').first(@cocina_json) ||
               JsonPath.new("$.description.identifier[?(@['type'] == 'doi')].value").first(@cocina_json) ||
               JsonPath.new("$.description.identifier[?(@['uri'] =~ /doi/)].uri").first(@cocina_json)
      return unless doi_id

      return [doi_id] if doi_id.start_with?('https://doi.org')

      [URI.join('https://doi.org', doi_id).to_s]
    end

    def object_access?
      # true if access.download = "world"
      return true if JsonPath.new("$.access[?(@['download'] == 'world')]").first(@cocina_json)

      false
    end

    def video_access?
      video = JsonPath.new("$.structural.contains[*][?(@['type'] == 'https://cocina.sul.stanford.edu/models/resources/video')]").on(@cocina_json)
      # need to find the file that is the one for the video (based on mime-type). Then get the access and download rights for that.
      file_access = JsonPath.new('$[*].structural.contains[*][?(@.hasMimeType =~ /video/)].access.download').first(video)

      file_access == 'world'
    end

    def license
      JsonPath.new('$.access.license').first(@cocina_json)
    end

    def url
      JsonPath.new('$.description.purl').first(@cocina_json)
    end

    def creators
      # contributor.identifier.uri or contributor.identifier.value with type "orcid" (case-insensitive), made into URI if identifier only
      creators = []
      contributors = JsonPath.new('$.description.contributor[*]').on(@cocina_json)

      contributors.each do |contributor|
        creators.push(
          { "@type": 'Person',
            "name": creator_name(contributor),
            "givenName": given_name(contributor),
            "familyName": family_name(contributor),
            "sameAs": orcid(contributor) }.compact
        )
      end

      creators
    end

    def creator_name(contributor)
      # contributor.name.value or concatenated contributor.name.structuredValue
      JsonPath.new('$.name.value').first(contributor) || structured_name(contributor)
    end

    def structured_name(contributor)
      # concatenated contributor.name.structuredValue
      [given_name(contributor), family_name(contributor)].join(' ')
    end

    def given_name(contributor)
      # contributor.name.structuredValue.value with type "forename"
      JsonPath.new("$.name[0].structuredValue[*].[?(@['type'] == 'forename')].value").first(contributor)
    end

    def family_name(contributor)
      # contributor.name.structuredValue.value with type "surname"
      JsonPath.new("$.name[0].structuredValue[*].[?(@['type'] == 'surname')].value").first(contributor)
    end

    def orcid(contributor)
      # contributor.identifier.uri or contributor.identifier.value with type "orcid" (case-insensitive), made into URI if identifier only
      identifier = JsonPath.new('$.identifier.uri').first(contributor)
      return identifier if identifier.present?

      orcid = JsonPath.new("$.identifier.[?(@['type'] == 'ORCID' || @['type'] == 'orcid')].value").first(contributor)
      return if orcid.blank?

      return orcid if orcid.start_with?('https://orcid.org')

      URI.join('https://orcid.org/', orcid).to_s
    end

    def embed_url
      iframe_url_template.expand(url: embeddable_url).to_s
    end

    def iframe_url_template
      Addressable::Template.new(Settings.embed.iframe.url_template)
    end

    def embeddable_url
      format(Settings.embed.url, druid: bare_druid)
    end

    def bare_druid
      druid.delete_prefix('druid:')
    end

    def druid
      JsonPath.new('$.externalIdentifier').first(@cocina_json)
    end

    def thumbnail
      # required for Videos
      # structural.contains.filename with hasMimeType = "image/jp2" where structural.contains has type https://cocina.sul.stanford.edu/models/resources/video",
      video = JsonPath.new("$.structural.contains[*][?(@['type'] == 'https://cocina.sul.stanford.edu/models/resources/video')]").on(@cocina_json)
      filename = JsonPath.new("$[*].structural.contains[*][?(@['hasMimeType'] == 'image/jp2')].filename").first(video)
      return if filename.blank?

      URI.join(Settings.stacks.url, "file/#{druid}/#{filename}").to_s
    end

    def upload_date
      # required for Videos
      # event.date.value or event.date.structuredValue.value with event.date.type "publication" and event.date.status "primary"
      # first event.date.value or event.date.structuredValue.value with event.date.type "publication"
      events = JsonPath.new('$.description.event[*]').on(@cocina_json)
      JsonPath.new("$[*].date[*][?(@['type'] == 'publication' && @['status'] == 'primary')].value").first(events) ||
        JsonPath.new("$[*].date[*][?(@['type'] == 'publication' && @['status'] == 'primary')].structuredValue[*].value").first(events) ||
        JsonPath.new("$[*].date[*][?(@['type'] == 'publication')].value").first(events) ||
        JsonPath.new("$[*].date[*][?(@['type'] == 'publication')].structuredValue[*].value").first(events) ||
        no_date_type(events) || no_event_type(events)
    end

    def no_date_type(events)
      # first event.date.value or event.date.structuredValue.value with event.type "publication" and event.date.type null
      return unless events.any?

      dates = JsonPath.new("$.[?(@['type']) == 'publication')].date[*].[?(@['value'])]").on(events)
      structured_dates = JsonPath.new("$.[?(@['type']) == 'publication')].date[*].structuredValue[*]").on(events)
      dates.concat(structured_dates)
      return unless dates.any?

      date_value(dates)
    end

    def no_event_type(events)
      # first event.date.value or event.date.structuredValue with event.type null and event.date.type null
      return unless events.any?

      events.select! { |event| event.key?('type') == false }
      dates = JsonPath.new('$[*].date[*]').on(events)
      return unless dates.any?

      date_value(dates)
    end

    def date_value(dates)
      dates.select! { |date| date.key?('type') == false }
      return unless dates.any?

      dates.first.fetch('value')
    end
  end
  # rubocop:enable Metrics/ClassLength
end
