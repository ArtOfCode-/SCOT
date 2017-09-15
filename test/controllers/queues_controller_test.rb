require 'test_helper'

class QueuesControllerTest < ActionDispatch::IntegrationTest
  test "should get spam" do
    get queues_spam_url
    assert_response :success
  end

  test "should get validation" do
    get queues_validation_url
    assert_response :success
  end

  test "should get deduping" do
    get queues_deduping_url
    assert_response :success
  end

end
