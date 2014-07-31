Purl::Application.routes.draw do
  get '/:id' => 'purl#index'
  get 'auth/:id' => 'purl#index'
  get ':id/embed' => 'embed#index'
  get ':id/embed-js' => 'embed#embed_js'
  get ':id/embed-html-json' => 'embed#embed_html_json'
end
