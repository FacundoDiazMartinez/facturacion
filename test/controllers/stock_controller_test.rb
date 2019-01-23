require 'test_helper'

class StockControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get stock_edit_url
    assert_response :success
  end

end
