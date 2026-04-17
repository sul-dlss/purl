# frozen_string_literal: true

# Represents a Purl with no releases (meta.json not found)
# See Releases for more details
class NullReleases
  def crawlable?
    false
  end

  def released_to_searchworks?
    false
  end

  def released_to_earthworks?
    false
  end
end
