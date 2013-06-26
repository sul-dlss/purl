Purl::Application.routes.draw do
  match '/:id' => 'purl#index'
  match ':id/embed' => 'embed#index'
  match ':id/embed-js' => 'embed#embed_js'
  match ':id/embed-html-json' => 'embed#embed_html_json'
  match 'auth/:id' => 'purl#index'
  match 'auth/:id.:format' => 'purl#index'
  match '/:id.:format' => 'purl#index'
end
