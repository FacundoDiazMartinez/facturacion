require 'test_helper'

class DebitPaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @debit_payment = debit_payments(:one)
  end

  test "should get index" do
    get debit_payments_url
    assert_response :success
  end

  test "should get new" do
    get new_debit_payment_url
    assert_response :success
  end

  test "should create debit_payment" do
    assert_difference('DebitPayment.count') do
      post debit_payments_url, params: { debit_payment: {  } }
    end

    assert_redirected_to debit_payment_url(DebitPayment.last)
  end

  test "should show debit_payment" do
    get debit_payment_url(@debit_payment)
    assert_response :success
  end

  test "should get edit" do
    get edit_debit_payment_url(@debit_payment)
    assert_response :success
  end

  test "should update debit_payment" do
    patch debit_payment_url(@debit_payment), params: { debit_payment: {  } }
    assert_redirected_to debit_payment_url(@debit_payment)
  end

  test "should destroy debit_payment" do
    assert_difference('DebitPayment.count', -1) do
      delete debit_payment_url(@debit_payment)
    end

    assert_redirected_to debit_payments_url
  end
end
