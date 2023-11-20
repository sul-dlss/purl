module Metadata
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
      {
        "@context": 'http://schema.org',
        "@type": schema_type,
        "name": title_name,
        "identifier": identifier,
        "description": description,
        "isAccessibleForFree": access,
        "license": license,
        "url": url,
        "creator": creators
      }.compact
    end

    def schema_type?
      dataset?
    end

    private

    def schema_type
      'Dataset' if dataset?
    end

    def dataset?
      # has a form with value of dataset and type of genre
      dataset = JsonPath.new("$.description.form[?(@['value'] == 'dataset' && @['type'] == 'genre')]").on(@cocina_json)
      return true if dataset.any?

      false
    end

    def title_name
      # title.value or concatenated title.structuredValue 1) for title with status "primary" if present 2) for first title
      # required for Datasets
      titles = JsonPath.new("$.description.title[?(@['status' == 'primary'])].structuredValue[*].value").on(@cocina_json)
      return titles.join('\n') unless titles.empty?

      JsonPath.new('$.description.title[0].value').first(@cocina_json)
    end

    def description
      # description.note where type=summary or type=abstract, concatenating with \n if multiple
      # required for Datasets
      notes = JsonPath.new("$.description.note[?(@['type'] == 'summary' || @['type'] == 'abstract')].value").on(@cocina_json)
      return notes.join('\n') unless notes.empty?

      # provide title (or other text?) in description if relevant note is missing
      title_name
    end

    def identifier
      # identification.doi or identifier.uri or identifier.value with type "doi" (case-insensitive), made into URI if identifier only
      identifier = JsonPath.new('$.identification.doi').first(@cocina_json) ||
                   JsonPath.new('$.description.identifier..uri').first(@cocina_json) ||
                   JsonPath.new("$.description.identifier[?(@['type'] == 'doi')].value").first(@cocina_json)
      return unless identifier

      return [identifier] if identifier.start_with?('https://doi.org')

      [URI.join('https://doi.org', identifier).to_s]
    end

    def access
      # true if access.download = "world"
      return true if JsonPath.new("$.access[?(@['download'] == 'world')]").first(@cocina_json)

      false
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
      id_uri = JsonPath.new('$.identifier.uri').first(contributor)
      return id_uri if id_uri.present?

      orcid = JsonPath.new("$.identifier.[?(@['type'] == 'ORCID' || @['type'] == 'orcid')].value").first(contributor)
      return if orcid.blank?

      return orcid if orcid.start_with?('https://orcid.org')

      URI.join('https://orcid.org/', orcid).to_s
    end
  end
end
