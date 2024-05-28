require 'dor/rights_auth'

class ReleaseMetadata
  attr_reader :metadata

  # @param [JSON] metadata
  def initialize(metadata)
    @metadata = metadata
  end

  def released_to?(key)
    release = metadata["releaseTags"]&.find { |tag| tag["to"] == key }&.fetch("release", nil)

    release == true
  end
end
