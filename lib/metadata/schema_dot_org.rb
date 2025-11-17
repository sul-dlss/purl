# frozen_string_literal: true

module Metadata
  class SchemaDotOrg
    attr_reader :cocina_display

    def self.call(cocina_display, thumbnail: nil)
      new(cocina_display, thumbnail:).call
    end

    def self.schema_type?(cocina_display)
      new(cocina_display).schema_type?
    end

    def initialize(cocina_display, thumbnail: nil)
      @cocina_json = cocina_display.cocina_doc
      @cocina_display = cocina_display
      @thumbnail = thumbnail
    end

    delegate :dataset?, :druid, to: :cocina_display

    def call
      { '@context': 'http://schema.org',
        '@type': schema_type,
        name: cocina_display.display_title,
        description: }
        .merge(format_specific_fields)
        .compact
    rescue StandardError
      Honeybadger.notify('Error occurred generating schema.org markup', context: { druid: })
      {}
    end

    def schema_type?
      dataset? || render_video_metadata?
    end

    private

    def schema_type
      return 'Dataset' if dataset?

      'VideoObject' if render_video_metadata?
    end

    def render_video_metadata?
      # Only return video metadata if world-downloadable.
      video = JsonPath.new("$.structural.contains[?(@['type'] == 'https://cocina.sul.stanford.edu/models/resources/video')]").on(@cocina_json)
      video.any? && object_access? && video_access?
    end

    def format_specific_fields
      if dataset?
        return { identifier: cocina_display.doi_url,
                 isAccessibleForFree: object_access?,
                 license: cocina_display.license,
                 url: cocina_display.purl_url,
                 creator: creators }
      elsif render_video_metadata?
        return { thumbnailUrl: @thumbnail,
                 uploadDate: upload_date,
                 embedUrl: embed_url }
      end
      {}
    end

    def description
      # description.note where type=summary or type=abstract, concatenating with \n if multiple
      # required for Datasets
      notes = cocina_display.abstract_display_data.flat_map(&:values) + cocina_display.general_note_display_data.flat_map(&:values)
      notes.join('\n') unless notes.empty?
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

    def creators
      cocina_display.contributors.map do |contributor|
        orcid_identifier = contributor.identifiers.find { it.type == 'ORCID' || it.uri.include?('orcid.org') }
        { '@type': 'Person',
          name: contributor.display_name,
          givenName: contributor.forename,
          familyName: contributor.surname,
          sameAs: orcid_identifier&.to_s }.compact
      end
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

    def thumbnail
      # required for Videos
      # structural.contains.filename with hasMimeType = "image/jp2" where structural.contains has type https://cocina.sul.stanford.edu/models/resources/video",
      video = JsonPath.new("$.structural.contains[*][?(@['type'] == 'https://cocina.sul.stanford.edu/models/resources/video')]").on(@cocina_json)
      filename = JsonPath.new("$[*].structural.contains[*][?(@['hasMimeType'] == 'image/jp2')].filename").first(video)
      return if filename.blank?

      # filenames need spaces escaped, while stacks expects other special characters such as ()
      escaped_filename = filename.gsub(' ', '%20')
      URI.join(Settings.stacks.url, "file/#{druid}/#{escaped_filename}").to_s
    rescue URI::InvalidURIError
      nil
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

      dates = JsonPath.new("$.[?(@.type == 'publication')].date[*].[?(@['value'])]").on(events)
      structured_dates = JsonPath.new("$.[?(@.type == 'publication')].date[*].structuredValue[*]").on(events)
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

      dates.first.fetch('value', nil)
    end
  end
end
