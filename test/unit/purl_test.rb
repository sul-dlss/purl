require 'test_helper'

class PurlTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "loading from the doc cache" do
    item=Purl.new('')
    assert item.is_ready?
  end
end
