require 'test_helper'

class QueuesControllerTest < ActionDispatch::IntegrationTest
  test "should get dedupe" do
    get queues_dedupe_url
    assert_response :success
  end

  test "should get dedupe_complete" do
    get queues_dedupe_complete_url
    assert_response :success
  end

  test "should get spam" do
    get queues_spam_url
    assert_response :success
  end

  test "should get spam_complete" do
    get queues_spam_complete_url
    assert_response :success
  end

  test "should get suggested_edit" do
    get queues_suggested_edit_url
    assert_response :success
  end

  test "should get suggested_edit_complete" do
    get queues_suggested_edit_complete_url
    assert_response :success
  end

end
