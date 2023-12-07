# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = Settings.sitemap.default_host
SitemapGenerator::Sitemap.sitemaps_path = 'public/system/sitemap/'

SitemapGenerator::Sitemap.create(include_root: false) do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end
  Settings.resource_cache.enabled = false
  PurlResource.all.each do |purl|
    add purl_path(purl.id), lastmod: purl.updated_at, changefreq: nil, priority: nil if purl.crawlable?
  rescue StandardError
    # Because data is bad.
  end
end
