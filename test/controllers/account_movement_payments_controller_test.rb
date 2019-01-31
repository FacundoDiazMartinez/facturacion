require 'test_helper'

class AccountMovementPaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account_movement_payment = account_movement_payments(:one)
  end

  test "should get index" do
    get account_movement_payments_url
    assert_response :success
  end

  test "should get new" do
    get new_account_movement_payment_url
    assert_response :success
  end

  test "should create account_movement_payment" do
    assert_difference('AccountMovementPayment.count') do
      post account_movement_payments_url, params: { account_movement_payment: {  } }
    end

    assert_redirected_to account_movement_payment_url(AccountMovementPayment.last)
  end

  test "should show account_movement_payment" do
    get account_movement_payment_url(@account_movement_payment)
    assert_response :success
  end

  test "should get edit" do
    get edit_account_movement_payment_url(@account_movement_payment)
    assert_response :success
  end

  test "should update account_movement_payment" do
    patch account_movement_payment_url(@account_movement_payment), params: { account_movement_payment: {  } }
    assert_redirected_to account_movement_payment_url(@account_movement_payment)
  end

  test "should destroy account_movement_payment" do
    assert_difference('AccountMovementPayment.count', -1) do
      delete account_movement_payment_url(@account_movement_payment)
    end

    assert_redirected_to account_movement_payments_url
  end
end
