require 'spec_helper'
#require 'purl'
describe PurlObject do
  it 'should create itself from the docs in the document cache' do
    item = PurlObject.new('bb157hs6068')
    item.is_ready?.should == true
  end
end