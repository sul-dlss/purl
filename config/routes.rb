Rails.application.routes.draw do

  root to: 'purl#index'

  get '/ir:rs276tc2764', to: redirect('/rs276tc2764')
  get ':id' => 'purl#show', as: :purl
  get '/:id/iiif/manifest.json' => 'purl#manifest', as: :iiif_manifest

  resource :feedback_form, path: "feedback", only: [:new, :create]
  get "feedback" => "feedback_forms#new"
end
