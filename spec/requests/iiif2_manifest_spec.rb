# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'IIIF v2 manifests' do
  let(:json) { response.parsed_body }

  context 'when the manifest generation is successful' do
    it 'is successful' do
      get '/bb157hs6068/iiif/manifest'

      expect(response).to have_http_status(:ok)

      expect(json['@context']).to eq 'http://iiif.io/api/presentation/2/context.json'
      expect(json['label']).to include 'NOUVELLE CARTE DE LA SPHERE POUR FAIRE CONNOITRE LES' # ...
    end
  end
end
