Rails.configuration.middleware.use(IsItWorking::Handler) do |h|
  h.check :directory, path: Settings.document_cache_root

  # Check the memcache servers used by Rails.cache if using the DalliStore implementation
  h.check :dalli, cache: Rails.cache if defined?(ActiveSupport::Cache::DalliStore) && Rails.cache.is_a?(ActiveSupport::Cache::DalliStore)
end
