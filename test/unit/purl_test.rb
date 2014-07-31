require 'test_helper'

class PurlTest < ActiveSupport::TestCase
  test "loading from the doc cache" do
    item=Purl.new('bb157hs6068')
    assert !item.nil?
    assert item.ready?
  end
end
