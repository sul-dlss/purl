class Description
  class CocinaIdentifier
    def initialize(cocina_json:)
      @cocina_json = cocina_json
    end

    # identification.doi or identifier.uri or identifier.value with type "doi" (case-insensitive), made into URI if identifier only
    # @return [String,nil] DOI (with https://doi.org/ prefix) if present
    def doi
      @doi ||= begin
        identifier = JsonPath.new('$.identification.doi').first(@cocina_json) ||
                     JsonPath.new('$.description.identifier..uri').first(@cocina_json) ||
                     JsonPath.new("$.description.identifier[?(@['type'] == 'doi')].value").first(@cocina_json)
        if identifier&.start_with?('https://doi.org')
          identifier
        elsif identifier
          URI.join('https://doi.org', identifier).to_s
        end
      end
    end

    # @return [String,nil] DOI (without https://doi.org/ prefix) if present
    def doi_id
      doi&.delete_prefix('https://doi.org/')
    end

    private

    attr_reader :cocina_json
  end
end
