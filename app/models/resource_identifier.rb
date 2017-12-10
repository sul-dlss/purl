class ResourceIdentifier
  def initialize(druid:, file_name:)
    @druid = druid
    @file_name = file_name
  end

  attr_reader :druid, :file_name
end
