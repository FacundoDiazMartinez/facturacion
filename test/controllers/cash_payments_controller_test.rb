require 'test_helper'

class CashPaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cash_payment = cash_payments(:one)
  end

  test "should get index" do
    get cash_payments_url
    assert_response :success
  end

  test "should get new" do
    get new_cash_payment_url
    assert_response :success
  end

  test "should create cash_payment" do
    assert_difference('CashPayment.count') do
      post cash_payments_url, params: { cash_payment: {  } }
    end

    assert_redirected_to cash_payment_url(CashPayment.last)
  end

  test "should show cash_payment" do
    get cash_payment_url(@cash_payment)
    assert_response :success
  end

  test "should get edit" do
    get edit_cash_payment_url(@cash_payment)
    assert_response :success
  end

  test "should update cash_payment" do
    patch cash_payment_url(@cash_payment), params: { cash_payment: {  } }
    assert_redirected_to cash_payment_url(@cash_payment)
  end

  test "should destroy cash_payment" do
    assert_difference('CashPayment.count', -1) do
      delete cash_payment_url(@cash_payment)
    end

    assert_redirected_to cash_payments_url
  end
end
