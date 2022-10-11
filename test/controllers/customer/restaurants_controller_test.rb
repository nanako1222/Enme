require "test_helper"

class Customer::RestaurantsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get customer_restaurants_show_url
    assert_response :success
  end

  test "should get index" do
    get customer_restaurants_index_url
    assert_response :success
  end

  test "should get create" do
    get customer_restaurants_create_url
    assert_response :success
  end
end
