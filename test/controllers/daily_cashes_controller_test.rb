require 'test_helper'

class DailyCashesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @daily_cash = daily_cashes(:one)
  end

  test "should get index" do
    get daily_cashes_url
    assert_response :success
  end

  test "should get new" do
    get new_daily_cash_url
    assert_response :success
  end

  test "should create daily_cash" do
    assert_difference('DailyCash.count') do
      post daily_cashes_url, params: { daily_cash: { company_id: @daily_cash.company_id, final_amount: @daily_cash.final_amount, initial_amount: @daily_cash.initial_amount, state: @daily_cash.state, user_id: @daily_cash.user_id } }
    end

    assert_redirected_to daily_cash_url(DailyCash.last)
  end

  test "should show daily_cash" do
    get daily_cash_url(@daily_cash)
    assert_response :success
  end

  test "should get edit" do
    get edit_daily_cash_url(@daily_cash)
    assert_response :success
  end

  test "should update daily_cash" do
    patch daily_cash_url(@daily_cash), params: { daily_cash: { company_id: @daily_cash.company_id, final_amount: @daily_cash.final_amount, initial_amount: @daily_cash.initial_amount, state: @daily_cash.state, user_id: @daily_cash.user_id } }
    assert_redirected_to daily_cash_url(@daily_cash)
  end

  test "should destroy daily_cash" do
    assert_difference('DailyCash.count', -1) do
      delete daily_cash_url(@daily_cash)
    end

    assert_redirected_to daily_cashes_url
  end
end
