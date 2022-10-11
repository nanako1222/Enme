require "test_helper"

class Customer::RestaurantMenuControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get customer_restaurant_menu_index_url
    assert_response :success
  end

  test "should get show" do
    get customer_restaurant_menu_show_url
    assert_response :success
  end
end
