host Settings.sitemap.host
sitemap :site do
  PurlResource.all.each do |r|
    url purl_url(r), last_mod: r.updated_at, change_freq: 'monthly'
  end
end

ping_with "https://#{host}/sitemap.xml"
