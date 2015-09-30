# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w(
  site.css
  purl_image.css
  purl_embed.css
  purl_flipbook.css
  purl_book.js
  purl_embed_jquery_plugin.js
  purl_embed.js
  purl_flipbook.js
  purl_image.js
  zpr.js
  zpr.css
  cselect.js
  cselect.css
)

Rails.application.config.asset_host = Settings.asset_host unless Settings.asset_host.blank?
