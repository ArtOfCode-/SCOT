require 'test_helper'

class MedicalStatusControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get medical_status_index_url
    assert_response :success
  end

  test "should get update" do
    get medical_status_update_url
    assert_response :success
  end

  test "should get edit" do
    get medical_status_edit_url
    assert_response :success
  end

end
