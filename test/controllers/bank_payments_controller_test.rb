require 'test_helper'

class BankPaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @bank_payment = bank_payments(:one)
  end

  test "should get index" do
    get bank_payments_url
    assert_response :success
  end

  test "should get new" do
    get new_bank_payment_url
    assert_response :success
  end

  test "should create bank_payment" do
    assert_difference('BankPayment.count') do
      post bank_payments_url, params: { bank_payment: {  } }
    end

    assert_redirected_to bank_payment_url(BankPayment.last)
  end

  test "should show bank_payment" do
    get bank_payment_url(@bank_payment)
    assert_response :success
  end

  test "should get edit" do
    get edit_bank_payment_url(@bank_payment)
    assert_response :success
  end

  test "should update bank_payment" do
    patch bank_payment_url(@bank_payment), params: { bank_payment: {  } }
    assert_redirected_to bank_payment_url(@bank_payment)
  end

  test "should destroy bank_payment" do
    assert_difference('BankPayment.count', -1) do
      delete bank_payment_url(@bank_payment)
    end

    assert_redirected_to bank_payments_url
  end
end
