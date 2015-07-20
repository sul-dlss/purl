require 'spec_helper'
# require 'purl'
describe PurlObject do
  it 'should create itself from the docs in the document cache' do
    item = PurlObject.new('bb157hs6068')
    expect(item).to be_ready
  end

  describe '.image?' do
    it 'should return true for the content type webarchive-seed' do
      item = PurlObject.new('ab123cd4567')
      item.instance_variable_set(:@type, 'webarchive-seed')
      item.instance_variable_set(:@extracted, true)
      expect(item.image?).to be_truthy
    end
    it 'should return false  for the content type file' do
      item = PurlObject.new('ab123cd4567')
      item.instance_variable_set(:@type, 'file')
      item.instance_variable_set(:@extracted, true)
      expect(item.image?).to be_falsey
    end
    it 'should return false  for the content type nil' do
      item = PurlObject.new('ab123cd4567')
      item.instance_variable_set(:@type, nil)
      item.instance_variable_set(:@extracted, true)
      expect(item.image?).to be_falsey
    end
  end
end
