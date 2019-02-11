require 'test_helper'

class AccountMovementsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account_movement = account_movements(:one)
  end

  test "should get index" do
    get account_movements_url
    assert_response :success
  end

  test "should get new" do
    get new_account_movement_url
    assert_response :success
  end

  test "should create account_movement" do
    assert_difference('AccountMovement.count') do
      post account_movements_url, params: { account_movement: {  } }
    end

    assert_redirected_to account_movement_url(AccountMovement.last)
  end

  test "should show account_movement" do
    get account_movement_url(@account_movement)
    assert_response :success
  end

  test "should get edit" do
    get edit_account_movement_url(@account_movement)
    assert_response :success
  end

  test "should update account_movement" do
    patch account_movement_url(@account_movement), params: { account_movement: {  } }
    assert_redirected_to account_movement_url(@account_movement)
  end

  test "should destroy account_movement" do
    assert_difference('AccountMovement.count', -1) do
      delete account_movement_url(@account_movement)
    end

    assert_redirected_to account_movements_url
  end
end
