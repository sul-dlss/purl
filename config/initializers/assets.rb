# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( site.css footer.css purl_image.css purl_embed.css purl_flipbook.css zpr.css jquery.js jquery.truncator.js controls.js cselect.js dragdrop.js effects.js footer.js prototype.js purl_book.js purl_embed_jquery_plugin.js purl_embed_jquery_plugin.uncompressed.js purl_embed.js purl_flipbook.js purl_image-ref.js purl_image.js zpr.js)
