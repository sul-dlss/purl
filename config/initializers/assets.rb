# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

Rails.application.config.asset_host = Settings.asset_host unless Settings.asset_host.blank?

Rails.application.config.assets.precompile += %w( print.css )
Rails.application.config.assets.precompile += %w( fileicons/*.png )
