require "test_helper"

class Restaurant::HomesControllerTest < ActionDispatch::IntegrationTest
  test "should get top" do
    get restaurant_homes_top_url
    assert_response :success
  end

  test "should get edit" do
    get restaurant_homes_edit_url
    assert_response :success
  end

  test "should get update" do
    get restaurant_homes_update_url
    assert_response :success
  end
end
