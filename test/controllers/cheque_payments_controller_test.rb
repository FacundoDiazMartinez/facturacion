require 'test_helper'

class ChequePaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cheque_payment = cheque_payments(:one)
  end

  test "should get index" do
    get cheque_payments_url
    assert_response :success
  end

  test "should get new" do
    get new_cheque_payment_url
    assert_response :success
  end

  test "should create cheque_payment" do
    assert_difference('ChequePayment.count') do
      post cheque_payments_url, params: { cheque_payment: {  } }
    end

    assert_redirected_to cheque_payment_url(ChequePayment.last)
  end

  test "should show cheque_payment" do
    get cheque_payment_url(@cheque_payment)
    assert_response :success
  end

  test "should get edit" do
    get edit_cheque_payment_url(@cheque_payment)
    assert_response :success
  end

  test "should update cheque_payment" do
    patch cheque_payment_url(@cheque_payment), params: { cheque_payment: {  } }
    assert_redirected_to cheque_payment_url(@cheque_payment)
  end

  test "should destroy cheque_payment" do
    assert_difference('ChequePayment.count', -1) do
      delete cheque_payment_url(@cheque_payment)
    end

    assert_redirected_to cheque_payments_url
  end
end
