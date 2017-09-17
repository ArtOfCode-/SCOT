require 'test_helper'

class RequestStatusControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get request_status_index_url
    assert_response :success
  end

  test "should get update" do
    get request_status_update_url
    assert_response :success
  end

  test "should get edit" do
    get request_status_edit_url
    assert_response :success
  end

end
