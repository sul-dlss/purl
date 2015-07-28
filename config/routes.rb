Rails.application.routes.draw do

  root to: 'purl#index'

  get '/ir:rs276tc2764', to: redirect('/rs276tc2764')
  get ':id' => 'purl#show', as: :purl
  get '/:id/iiif/manifest.json' => 'purl#manifest', as: :iiif_manifest

  get 'feedback' => 'feedback#new'
end
