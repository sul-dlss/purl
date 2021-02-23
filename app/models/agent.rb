# Information about a user including their user_key,
# stanford affiliation and location
class Agent
  def initialize(options = {})
    @options = options.slice(:user_key, :stanford, :location)
  end

  # @return [String] an IP address
  def location
    @options[:location]
  end

  def stanford?
    @options[:stanford]
  end

  def user_key
    @options[:user_key]
  end
end
