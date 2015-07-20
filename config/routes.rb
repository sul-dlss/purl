Purl::Application.routes.draw do
  unless Rails.application.config.assets.compile
    get '/assets/purl_embed_jquery_plugin' => 'embed#purl_embed_jquery_plugin'
  end

  get '/ir:rs276tc2764', to: redirect('/rs276tc2764')
  get '/:id' => 'purl#show'
  get 'auth/:id' => 'purl#show'
  get ':id/embed' => 'embed#show'
  get ':id/embed-js' => 'embed#embed_js'
  get ':id/embed-html-json' => 'embed#embed_html_json'
  get '/:id/iiif/manifest.json' => 'purl#manifest'
end
