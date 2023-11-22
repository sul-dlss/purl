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

    def desc
      @desc ||= Description.new(cocina_json: @cocina_json)
    end

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
      desc.formatted_title
    end

    def description
      desc.formatted_description || title_name
    end

    def identifier
      [desc.doi].compact.presence
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
      desc.contributors.map do |contributor|
        { "@type": 'Person',
          "name": contributor.name,
          "givenName": contributor.forename,
          "familyName": contributor.surname,
          "sameAs": contributor.orcid }.compact
      end
    end
  end
end
