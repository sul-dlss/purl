# frozen_string_literal: true

class ResourceCache
  include ActiveSupport::Benchmarkable

  delegate :logger, to: :Rails

  def get(url_or_path, cache_key)
    cache_resource(cache_key) do
      fetch_resource(url_or_path)
    end
  end

  private

  def fetch_resource(url_or_path)
    benchmark "Fetching #{url_or_path}" do
      case url_or_path
      when /^http/
        Faraday.get(url_or_path)
      else
        DocumentCacheResource.new(url_or_path)
      end
    end
  end

  def cache_resource(cache_key, &)
    if Settings.resource_cache.enabled
      Rails.cache.fetch(cache_key, expires_in: Settings.resource_cache.lifetime, &)
    else
      yield
    end
  end
end
