module Metadata
  class SchemaDotOrg
    def self.call(cocina_json)
      new(cocina_json).call
    end

    def self.schema_type?(cocina_json)
      new(cocina_json).schema_type?
    end

    def initialize(cocina_json)
      @cocina_json = JSON.parse(cocina_json)
    end

    def call
      {
        "@context": 'http://schema.org',
        "@type": schema_type,
        "name": title_name,
        "identifier": identifier,
        "description": description
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
      forms = @cocina_json['description'].fetch('form', nil)
      return false unless forms

      return true if forms.find { |form| form['value'] == 'dataset' && form['type'] == 'genre' }

      false
    end

    def title_name
      # title.value or concatenated title.structuredValue 1) for title with status "primary" if present 2) for first title
      titles = @cocina_json.dig('description', 'title')
      return unless titles

      primary_title = titles.select { |title| title['status'] == 'primary' }
      return primary_title.first['structuredValue'].pluck('value').join('\n') unless primary_title.empty?

      titles.first['value']
    end

    def description
      # get note where type=summary or type=abstract, concatenating with \n if multiple
      notes = @cocina_json['description'].fetch('note', nil)
      return unless notes

      notes.select! { |note| note.fetch('type', nil) == ('summary' || 'abstract') && note.fetch('value', nil) }
      notes.pluck('value').join('\n')
    end

    def identifier
      # identification.doi or identifier.uri or identifier.value with type "doi" (case-insensitive), made into URI if identifier only
      identification = @cocina_json.dig('identification', 'doi')
      return ["https://doi.org/#{identification}"] if identification

      desc_identifiers = @cocina_json.dig('description', 'identifier')
      return if desc_identifiers.empty?

      doi = desc_identifiers.find { |id| id['uri'] } || desc_identifiers.find { |id| id['value'] && id['type'] == 'doi' }
      doi_value = doi['uri'] || doi['value']
      return [doi_value] if doi_value.include?('https://doi.org')

      ["https://doi.org/#{doi_value}"]
    end
  end
end
