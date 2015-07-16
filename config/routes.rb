Purl::Application.routes.draw do
  unless Rails.application.config.assets.compile
    get '/assets/purl_embed_jquery_plugin' => 'embed#purl_embed_jquery_plugin'
  end

  get '/:id' => 'purl#index'
  get 'auth/:id' => 'purl#index'
  get ':id/embed' => 'embed#index'
  get ':id/embed-js' => 'embed#embed_js'
  get ':id/embed-html-json' => 'embed#embed_html_json'
  get '/:id/iiif/manifest.json' => 'purl#manifest'
end
