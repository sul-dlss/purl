require 'test_helper'

class PurlControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test 'should get show action' do
    get :show, 'id' => 'bb157hs6068'
    assert_response :success
    assert_not_nil assigns(:purl)
  end
  test 'should get mods' do
    get :show, 'id' => 'bb157hs6068'
    assert_response :success
    assert_not_nil assigns(:purl)
  end
end
