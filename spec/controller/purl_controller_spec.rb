require 'spec_helper'

describe PurlController, type: :controller do
  it 'should render for a published item' do
    visit '/bb157hs6068'
  end
end
