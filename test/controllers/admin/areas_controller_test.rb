require "test_helper"

class Admin::AreasControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_areas_index_url
    assert_response :success
  end
end
