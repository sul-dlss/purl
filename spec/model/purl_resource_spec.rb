require 'rails_helper'

describe PurlResource do
  it 'should create itself from the docs in the document cache' do
    item = PurlResource.find('bb157hs6068')
    expect(item).to be_ready
  end
end
