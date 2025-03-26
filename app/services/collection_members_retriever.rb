class CollectionMembersRetriever
  include ActiveSupport::Benchmarkable

  def initialize(druid:)
    @druid = druid
  end

  # All objects that list this object as a containing collection in purl-fetcher
  # TODO: exploit the structure of this response for caching purposes:
  # purl-fetcher lists most recently changed members first and sends an ETag
  #
  # Alternatively, use ActiveRecord hooks in purl-fetcher’s database to
  # update the collection’s timestamp when its members are modified
  #
  # For now, no caching until we know we need it
  def collection_members
    @collection_members ||= benchmark "Fetching #{druid} collection_members at #{collection_members_path}" do
      purl_fetcher_client.collection_members(druid).to_a
    end
  end

  private

  attr_reader :druid

  def logger
    Rails.logger
  end

  def purl_fetcher_client
    @purl_fetcher_client ||= PurlFetcher::Client::Reader.new(host: Settings.purl_fetcher.url)
  end

  # For logging purposes
  def collection_members_path
    "#{purl_fetcher_client.host}/collections/#{druid}/purls"
  end
end
