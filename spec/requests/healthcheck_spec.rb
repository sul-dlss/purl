# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Healthcheck endpoint (app monitoring)' do
  it 'has response code 200' do
    get '/status'
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Application is running')
  end
end
