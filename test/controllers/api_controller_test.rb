require 'test_helper'

class ApiControllerTest < ActionDispatch::IntegrationTest
  test "should get geojson" do
    get api_geojson_url
    assert_response :success
  end

  test "should get csv" do
    get api_csv_url
    assert_response :success
  end

end
