# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'IIIF Annotation Page' do
  context 'when using v3' do
    it 'renders the json for manifest' do
      get '/bc854fy5899/iiif3/annotation_page/cocina-fileSet-bc854fy5899-bc854fy5899_1'
      expect(response.parsed_body['items'].first['motivation']).to eq('painting')
    end

    it 'renders nil for a non-manifest' do
      get '/wp335yr5649/iiif3/annotation_page/bc854fy5899_fdsa'
      expect(response).to have_http_status(:not_found)
    end

    it 'renders the json for a jpeg file' do
      get '/cg357zz0321/iiif3/annotation_page/cocina-fileSet-cg357zz0321-cg357zz0321_1'
      expect(response).to have_http_status(:ok)
    end
  end
end
