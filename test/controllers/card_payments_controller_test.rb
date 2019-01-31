require 'test_helper'

class CardPaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @card_payment = card_payments(:one)
  end

  test "should get index" do
    get card_payments_url
    assert_response :success
  end

  test "should get new" do
    get new_card_payment_url
    assert_response :success
  end

  test "should create card_payment" do
    assert_difference('CardPayment.count') do
      post card_payments_url, params: { card_payment: {  } }
    end

    assert_redirected_to card_payment_url(CardPayment.last)
  end

  test "should show card_payment" do
    get card_payment_url(@card_payment)
    assert_response :success
  end

  test "should get edit" do
    get edit_card_payment_url(@card_payment)
    assert_response :success
  end

  test "should update card_payment" do
    patch card_payment_url(@card_payment), params: { card_payment: {  } }
    assert_redirected_to card_payment_url(@card_payment)
  end

  test "should destroy card_payment" do
    assert_difference('CardPayment.count', -1) do
      delete card_payment_url(@card_payment)
    end

    assert_redirected_to card_payments_url
  end
end
