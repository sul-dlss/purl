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

  get ':id/file/:file' => 'purl#file', as: :purl_file
  get ':id/metrics' => 'purl#metrics', as: :purl_metrics


  resources :purl, only: [:show], path: '/' do
    member do
      get 'version/:version', to: 'purl#show', as: :version
      get 'version/:version/iiif3/manifest', to: 'iiif#manifest', format: false, defaults: { iiif_version: 'v3', iiif_scope: 'iiif3' }

      get 'embed', to: redirect("/iframe/?url=#{Settings.embed.url % { druid: '%{id}' }}")
      # These routes should only be used until our viewers support v3 manifests.
      # We should aim to only serve a IIIF resource from a single URL.
      scope :iiif3, as: :iiif3, format: false, defaults: { iiif_version: 'v3', iiif_scope: 'iiif3' } do
        get 'manifest', to: 'iiif#manifest'
        get 'manifest.json', to: redirect('/%{id}/iiif3/manifest'), format: false

        get 'canvas/:resource_id', to: 'iiif#canvas', as: :canvas, format: false, defaults: { iiif_version: 'v3' }
        get 'canvas/:resource_id.json', to: redirect('/%{id}/iiif3/canvas/%{resource_id}'), format: false

        get 'annotation_page/:resource_id' => 'iiif#annotation_page', as: :annotation_page, format: false, defaults: { iiif_version: 'v3' }
        get 'annotation_page/:resource_id.json', to: redirect('/%{id}/iiif3/annotation_page/%{resource_id}'), format: false

        get 'annotation/:resource_id' => 'iiif#annotation', as: :annotation, format: false, defaults: { iiif_version: 'v3' }
        get 'annotation/:resource_id.json', to: redirect('/%{id}/iiif3/annotation/%{resource_id}'), format: false
      end

      scope :iiif, as: :iiif do
        #
        # Sets up the ability to specify an Accept header which should provide a v3
        # manifest. Eventually, v3 should be served by default.
        scope format: true, constraints: AcceptHeaderConstraint.new do
          get 'manifest', to: 'iiif#manifest', format: false, defaults: { iiif_version: 'v3' }
          get 'manifest.json', to: redirect('/%{id}/iiif/manifest'), format: false

          get 'canvas/:resource_id', to: 'iiif#canvas', format: false, defaults: { iiif_version: 'v3' }
          get 'canvas/:resource_id.json', to: redirect('/%{id}/iiif/canvas/%{resource_id}'), format: false

          get 'annotation_page/:resource_id' => 'iiif#annotation_page', format: false, defaults: { iiif_version: 'v3' }
          get 'annotation_page/:resource_id.json', to: redirect('/%{id}/iiif/annotation_page/%{resource_id}'), format: false

          get 'annotation/:resource_id' => 'iiif#annotation', format: false, defaults: { iiif_version: 'v3' }
          get 'annotation/:resource_id.json', to: redirect('/%{id}/iiif/annotation/%{resource_id}'), format: false
        end

        get 'manifest', to: 'iiif#manifest', format: false
        get 'manifest.json', to: redirect('/%{id}/iiif/manifest'), format: false

        get 'canvas/:resource_id', to: 'iiif#canvas', as: :canvas, format: false
        get 'canvas/:resource_id.json', to: redirect('/%{id}/iiif/canvas/%{resource_id}'), format: false

        get 'annotationList/:resource_id' => 'iiif#annotation_list', as: :annotation_list, format: false
        get 'annotationList/:resource_id.json', to: redirect('/%{id}/iiif/annotationList/%{resource_id}'), format: false

        get 'annotation/:resource_id' => 'iiif_#annotation', as: :annotation, format: false
        get 'annotation/:resource_id.json', to: redirect('/%{id}/iiif/annotation/%{resource_id}'), format: false
      end
    end
  end

  options '/:id', to: 'purl#options'

  scope constraints: AcceptHeaderConstraint.new do
    options '/:id/*whatever', to: 'iiif#options', defaults: { iiif_version: 'v3' }
  end

  options '/:id/*whatever', to: 'iiif#options'
end

Rails.application.routes.named_routes.path_helpers_module.module_eval do
  # @param [PurlVersion] a PurlVersion object
  # @return path for the show route
  def purl_version_path(purl_version, options = {})
    version_purl_path(id: purl_version.druid, version: purl_version.version_id)
  end
end
