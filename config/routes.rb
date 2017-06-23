Rails.application.routes.draw do
  root to: 'purl#index'

  # handle the singe static grandfathered exception (the first druid/PURL we ever issued for publication)
  get '/ir:rs276tc2764', to: redirect('/rs276tc2764')

  resource :feedback_form, path: 'feedback', only: [:new, :create]
  get 'feedback' => 'feedback_forms#new'

  get 'auth' => 'webauth#login', as: :new_user_session

  get ':id' => 'purl#show', as: :purl
  get ':id/embed', to: redirect("/iframe/?url=#{Settings.embed.url % { druid: '%{id}' }}")
  get '/:id/iiif/manifest' => 'iiif_v2#manifest', as: :iiif_manifest
  get '/:id/iiif/canvas/:resource_id' => 'iiif_v2#canvas', as: :iiif_canvas
  get '/:id/iiif/annotation/:annotation_id' => 'iiif_v2#annotation', as: :iiif_annotation

  get '/:id/iiif3/manifest' => 'iiif_v3#manifest', as: :iiif3_manifest
  get '/:id/iiif3/canvas/:resource_id' => 'iiif_v3#canvas', as: :iiif3_canvas
  get '/:id/iiif3/annotation/:annotation_id' => 'iiif_v3#annotation', as: :iiif3_annotation
end
