class Description
  class CocinaContributor
    def initialize(cocina_json:)
      @cocina_json = cocina_json
    end

    # @return [Array<Description::Contributor>] contributors
    def contributors
      @contributors ||= cocina_contributors.map { |cocina_contributor| contributor(cocina_contributor) }
    end

    # @return [Array<String>] contributors
    def formatted_contributors
      @formatted_contributors ||= contributors.map(&:name)
    end

    private

    attr_reader :cocina_json

    def cocina_contributors
      JsonPath.new('$.description.contributor[*]').on(@cocina_json)
    end

    def contributor(cocina_contributor)
      Description::Contributor.new(
        **ContributorBuilder.new(cocina_contributor:).build
      )
    end

    class ContributorBuilder
      def initialize(cocina_contributor:)
        @cocina_contributor = cocina_contributor
      end

      def build
        { name:,
          forename:,
          surname:,
          orcid: }.compact
      end

      private

      attr_reader :cocina_contributor

      def name
        # contributor.name.value or concatenated contributor.name.structuredValue
        JsonPath.new('$.name.value').first(cocina_contributor) || structured_name
      end

      def structured_name
        # concatenated contributor.name.structuredValue
        [forename, surname].join(' ')
      end

      def forename
        # contributor.name.structuredValue.value with type "forename"
        JsonPath.new("$.name[0].structuredValue[*].[?(@['type'] == 'forename')].value").first(cocina_contributor)
      end

      def surname
        # contributor.name.structuredValue.value with type "surname"
        JsonPath.new("$.name[0].structuredValue[*].[?(@['type'] == 'surname')].value").first(cocina_contributor)
      end

      def orcid
        # contributor.identifier.uri or contributor.identifier.value with type "orcid" (case-insensitive), made into URI if identifier only
        id_uri = JsonPath.new('$.identifier.uri').first(cocina_contributor)
        return id_uri if id_uri.present?

        orcid = JsonPath.new("$.identifier.[?(@['type'] == 'ORCID' || @['type'] == 'orcid')].value").first(cocina_contributor)
        return if orcid.blank?

        return orcid if orcid.start_with?('https://orcid.org')

        URI.join('https://orcid.org/', orcid).to_s
      end
    end
  end
end
