Rails.configuration.middleware.use(IsItWorking::Handler) do |h|
  h.check :directory, path: Settings.document_cache_root
end
