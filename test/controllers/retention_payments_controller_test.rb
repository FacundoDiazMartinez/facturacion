require 'test_helper'

class RetentionPaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @retention_payment = retention_payments(:one)
  end

  test "should get index" do
    get retention_payments_url
    assert_response :success
  end

  test "should get new" do
    get new_retention_payment_url
    assert_response :success
  end

  test "should create retention_payment" do
    assert_difference('RetentionPayment.count') do
      post retention_payments_url, params: { retention_payment: {  } }
    end

    assert_redirected_to retention_payment_url(RetentionPayment.last)
  end

  test "should show retention_payment" do
    get retention_payment_url(@retention_payment)
    assert_response :success
  end

  test "should get edit" do
    get edit_retention_payment_url(@retention_payment)
    assert_response :success
  end

  test "should update retention_payment" do
    patch retention_payment_url(@retention_payment), params: { retention_payment: {  } }
    assert_redirected_to retention_payment_url(@retention_payment)
  end

  test "should destroy retention_payment" do
    assert_difference('RetentionPayment.count', -1) do
      delete retention_payment_url(@retention_payment)
    end

    assert_redirected_to retention_payments_url
  end
end
