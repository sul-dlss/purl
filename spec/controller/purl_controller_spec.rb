require 'rails_helper'

RSpec.describe PurlController, type: :controller do
  it 'redirects to stacks urls' do
    response = get :file, params: { id: 'bb157hs6068', file: 'xyz' }
    expect(response).to redirect_to 'https://stacks.stanford.edu/file/druid:bb157hs6068/xyz'
  end

  it 'redirects to stacks zip urls' do
    response = get :show, format: 'zip', params: { id: 'bb157hs6068' }
    expect(response).to redirect_to 'https://stacks.stanford.edu/object/bb157hs6068.zip'
  end
end
