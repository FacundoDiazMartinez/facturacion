require 'test_helper'

class SendedAdvertisementControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get sended_advertisement_new_url
    assert_response :success
  end

  test "should get create" do
    get sended_advertisement_create_url
    assert_response :success
  end

  test "should get show" do
    get sended_advertisement_show_url
    assert_response :success
  end

end
