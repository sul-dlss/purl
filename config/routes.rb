##
# Routing for PURL
#
# IIIF Routing
# v3 if a client specifically requests v3 via URL or Accept headers
# v2 by default
Rails.application.routes.draw do
  root to: 'purl#index'

  # handle the singe static grandfathered exception (the first druid/PURL we ever issued for publication)
  get '/ir:rs276tc2764', to: redirect('/rs276tc2764')

  resource :feedback_form, path: 'feedback', only: [:new, :create]
  get 'feedback' => 'feedback_forms#new'

  get 'auth' => 'webauth#login', as: :new_user_session
  get '/preview' => 'preview#index'
  post '/preview' => 'preview#show'

  get ':id' => 'purl#show', as: :purl
  get ':id/embed', to: redirect("/iframe/?url=#{Settings.embed.url % { druid: '%{id}' }}")
  get ':id/file/:file' => 'purl#file', as: :purl_file

  ##
  # These routes should only be used until our viewers support v3 manifests.
  # We should aim to only serve a IIIF resource from a single URL.
  get '/:id/iiif3/manifest' => 'iiif_v3#manifest', as: :iiif3_manifest, format: false
  get '/:id/iiif3/manifest.json', to: redirect('/%{id}/iiif3/manifest')

  get '/:id/iiif3/canvas/:resource_id' => 'iiif_v3#canvas', as: :iiif3_canvas, format: false
  get '/:id/iiif3/canvas/:resource_id.json', to: redirect('/%{id}/iiif3/canvas/%{resource_id}')

  get '/:id/iiif3/annotation_page/:annotation_page_id' => 'iiif_v3#annotation_page', as: :iiif3_annotation_page, format: false
  get '/:id/iiif3/annotation_page/:annotation_page_id.json', to: redirect('/%{id}/iiif3/annotation_page/%{annotation_page_id}')

  get '/:id/iiif3/annotation/:annotation_id' => 'iiif_v3#annotation', as: :iiif3_annotation, format: false
  get '/:id/iiif3/annotation/:annotation_id.json', to: redirect('/%{id}/iiif3/annotation/%{annotation_id}')

  ##
  # Sets up the ability to specify an Accept header which should provide a v3
  # manifest. Eventually, v3 should be served by default.
  scope format: true, constraints: AcceptHeaderConstraint.new do
    get '/:id/iiif/manifest' => 'iiif_v3#manifest', format: false
    get '/:id/iiif/manifest.json', to: redirect('/%{id}/iiif3/manifest')

    get '/:id/iiif/canvas/:resource_id' => 'iiif_v3#canvas', format: false
    get '/:id/iiif/canvas/:resource_id.json', to: redirect('/%{id}/iiif3/canvas/%{resource_id}')

    get '/:id/iiif/annotation_page/:annotation_page_id' => 'iiif_v3#annotation_page', format: false
    get '/:id/iiif/annotation_page/:annotation_page_id.json', to: redirect('/%{id}/iiif3/annotation_page/%{annotation_page_id}')

    get '/:id/iiif/annotation/:annotation_id' => 'iiif_v3#annotation', format: false
    get '/:id/iiif/annotation/:annotation_id.json', to: redirect('/%{id}/iiif3/annotation/%{annotation_id}')
  end

  ##
  # Default to IIIF Presentatation API v2 until our clients support v3.
  get '/:id/iiif/manifest' => 'iiif_v2#manifest', as: :iiif_manifest, format: false
  get '/:id/iiif/manifest.json', to: redirect('/%{id}/iiif/manifest')

  get '/:id/iiif/canvas/:resource_id' => 'iiif_v2#canvas', as: :iiif_canvas, format: false
  get '/:id/iiif/canvas/:resource_id.json', to: redirect('/%{id}/iiif/canvas/%{resource_id}')

  get '/:id/iiif/annotation/:annotation_id' => 'iiif_v2#annotation', as: :iiif_annotation, format: false
  get '/:id/iiif/annotation/:annotation_id.json', to: redirect('/%{id}/iiif/annotation/%{annotation_id}')
end
