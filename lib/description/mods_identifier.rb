class Description
  class ModsIdentifier
    MODS_NS = 'http://www.loc.gov/mods/v3'.freeze

    def initialize(mods_ng:)
      @mods_ng = mods_ng
    end

    # @return [String,nil] DOI (with https://doi.org/ prefix) if present
    def doi
      @doi ||= mods_ng.root&.at_xpath('mods:identifier[@type="doi"]', mods: MODS_NS)&.text
    end

    # @return [String,nil] DOI (without https://doi.org/ prefix) if present
    def doi_id
      doi&.delete_prefix('https://doi.org/')
    end

    private

    attr_reader :mods_ng
  end
end
