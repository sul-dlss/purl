require 'rails_helper'

describe PurlController, type: :controller do
  it 'should render for a published item' do
    get :show, params: { id: '/bb157hs6068' }
  end
end
