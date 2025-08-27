# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Metrics API' do
  context 'when the object is not found' do
    it 'returns a 404 status code' do
      get '/xx000xx0000/metrics'

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include 'The item you requested is not available.'
    end
  end
end
