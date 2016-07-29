Rails.configuration.middleware.use(IsItWorking::Handler) do |h|
  h.check :directory, path: Settings.document_cache_root

  # Check the memcache servers used by Rails.cache if using the DalliStore implementation
  h.check :dalli, cache: Rails.cache if defined?(ActiveSupport::Cache::DalliStore) && Rails.cache.is_a?(ActiveSupport::Cache::DalliStore)

  h.check :url, get: Settings.stacks.url
  h.check :url, get: Settings.stacks.iiif_profile

  h.check :url, get: Settings.flipbook.url
  h.check :url, get: 'https://embed.stanford.edu'
end
