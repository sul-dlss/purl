class Description
  class CocinaTitle
    def initialize(cocina_json:)
      @cocina_json = cocina_json
    end

    # Concatenated title.structuredValue for title with status "primary" if present
    # Otherwise, title.value for first title
    # @return [String, nil] formatted title
    def formatted_title(delimiter: '\n')
      @formatted_title ||= begin
        titles = JsonPath.new("$.description.title[?(@['status' == 'primary'])].structuredValue[*].value").on(cocina_json)
        if titles.present?
          titles.join(delimiter)
        else
          JsonPath.new('$.description.title[0].value').first(cocina_json)
        end
      end
    end

    private

    attr_reader :cocina_json
  end
end
