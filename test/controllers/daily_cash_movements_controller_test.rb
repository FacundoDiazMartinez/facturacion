require 'test_helper'

class DailyCashMovementsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get daily_cash_movements_show_url
    assert_response :success
  end

end
