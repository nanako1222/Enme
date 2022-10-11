require "test_helper"

class Admin::AllergysControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_allergys_index_url
    assert_response :success
  end

  test "should get create" do
    get admin_allergys_create_url
    assert_response :success
  end

  test "should get edit" do
    get admin_allergys_edit_url
    assert_response :success
  end

  test "should get update" do
    get admin_allergys_update_url
    assert_response :success
  end
end
