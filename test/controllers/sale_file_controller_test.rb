require 'test_helper'

class SaleFileControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get sale_file_index_url
    assert_response :success
  end

  test "should get show" do
    get sale_file_show_url
    assert_response :success
  end

end
