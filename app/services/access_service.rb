class AccessService
  # @param level [String] What level of access is being requested
  # @param agent [Agent] Who is making the request
  # @param identifier [ResourceIdentifier] What resource is being requested
  def initialize(level:, agent:, identifier:)
    @level = level
    @agent = agent
    @identifier = identifier
  end

  def authorized?
    case @level
    when 'read'
      readable_by?(@agent)
    when 'access'
      accessable_by?(@agent)
    when 'download'
      readable_by?(@agent) # We may need to add more here about projection size?
    end
  end

  private

  def id
    @identifier
  end

  def readable_by?(user)
    world_downloadable? ||
      (stanford_only_downloadable? && user.stanford?) ||
      # (agent_downloadable?(user.user_key) && user.app_user?) ||
      location_downloadable?(user.location)
  end

  def accessable_by?(user)
    world_accessable? ||
      (stanford_only_accessable? && user.stanford?) ||
      agent_accessable?(user) ||
      location_accessable?(user.location)
  end

  def maybe_downloadable?
    world_unrestricted? || stanford_only_unrestricted?
  end

  def stanford_restricted?
    stanford_only_rights.first
  end

  # Returns true if a given file has any location restrictions.
  #   Falls back to the object-level behavior if none at file level.
  def restricted_by_location?
    rights.restricted_by_location?(id.file_name)
  end

  # Returns [<Boolean>, <String>]: whether a file-level group/stanford node exists, and the value of its rule attribute
  #   If a group/stanford node does not exist for this file, then object-level group/stanford rights are returned
  def stanford_only_rights
    rights.stanford_only_rights_for_file id.file_name
  end

  # Returns [<Boolean>, <String>]: whether a file-level location exists, and the value of its rule attribute
  #   If a location node does not exist for this file, then object-level location rights are returned
  def location_rights(location)
    rights.location_rights_for_file(id.file_name, location)
  end

  def world_accessable?
    world_rights.first
  end

  def agent_accessable?(user)
    agent_rights_defined = agent_rights(user.user_key).first
    agent_rights_defined && user.app_user?
  end

  def location_accessable?(location)
    location_rights(location).first
  end

  def world_unrestricted?
    rights.world_unrestricted_file? id.file_name
  end

  def world_downloadable?
    rights.world_downloadable_file? id.file_name
  end

  # Returns [<Boolean>, <String>]: whether a file-level world node exists, and the value of its rule attribute
  #   If a world node does not exist for this file, then object-level world rights are returned
  def world_rights
    rights.world_rights_for_file id.file_name
  end

  def stanford_only_downloadable?
    rights.stanford_only_downloadable_file? id.file_name
  end

  def stanford_only_accessable?
    stanford_only_rights.first
  end

  # Returns true if the file is stanford-only readable AND has no rule attribute
  #   If a stanford node does not exist for this file, then object-level stanford rights are returned
  def stanford_only_unrestricted?
    rights.stanford_only_unrestricted_file? id.file_name
  end

  # Returns [<Boolean>, <String>]: whether a file-level agent node exists, and the value of its rule attribute
  #   If an agent node does not exist for this file, then object-level agent rights are returned
  def agent_rights(agent)
    rights.agent_rights_for_file id.file_name, agent
  end

  def agent_downloadable?(agent)
    value, rule = agent_rights(agent)
    value && (rule.nil? || rule != Dor::RightsAuth::NO_DOWNLOAD_RULE)
  end

  def restricted_locations
    if rights.file[file_name]
      rights.file[file_name].location.keys
    else
      rights.obj_lvl.location.keys
    end
  end

  def location_downloadable?(location)
    value, rule = location_rights(location)
    value && (rule.nil? || rule != Dor::RightsAuth::NO_DOWNLOAD_RULE)
  end

  def rights
    @rights ||= resource.rights.rights_auth
  end

  def resource
    @resource ||= PurlResource.find(@identifier.druid)
  end
end
