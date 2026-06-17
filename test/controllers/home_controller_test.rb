require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get home_show_url
    assert_response :success
  end

  test "gen requires login" do
    post home_gen_url, params: { url: 'https://example.com' }

    assert_response :unauthorized
  end
end
