class Description
  class CocinaNote
    def initialize(cocina_json:)
      @cocina_json = cocina_json
    end

    # value for description.note where type=summary or type=abstract
    # @return [Array<String>] description notes
    def descriptions
      @descriptions ||= JsonPath.new("$.description.note[?(@['type'] == 'summary' || @['type'] == 'abstract')].value").on(cocina_json)
    end

    # @return [String, nil] formatted description
    def formatted_description(delimiter: '\n')
      @formatted_description ||= descriptions.join(delimiter) unless descriptions.empty?
    end

    private

    attr_reader :cocina_json
  end
end
