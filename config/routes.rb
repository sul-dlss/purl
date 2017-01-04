Rails.application.routes.draw do
  root to: 'purl#index'

  # handle the singe static grandfathered exception (the first druid/PURL we ever issued for publication)
  get '/ir:rs276tc2764', to: redirect('/rs276tc2764')

  resource :feedback_form, path: 'feedback', only: [:new, :create]
  get 'feedback' => 'feedback_forms#new'

  get 'auth' => 'webauth#login', as: :new_user_session

  get ':id' => 'purl#show', as: :purl
  get ':id/embed', to: redirect("/iframe/?url=#{Settings.embed.url % { druid: '%{id}' }}")
  get '/:id/iiif/manifest' => 'purl#manifest', as: :iiif_manifest
  get '/:id/iiif/canvas/:resource_id' => 'purl#canvas', as: :iiif_canvas
  get '/:id/iiif/annotation/:annotation_id' => 'purl#annotation', as: :iiif_annotation
end
