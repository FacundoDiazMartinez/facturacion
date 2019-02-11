require 'test_helper'

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  test "should get destroy" do
    get payments_destroy_url
    assert_response :success
  end

end
