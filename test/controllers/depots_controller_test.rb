require 'test_helper'

class DepotsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @depot = depots(:one)
  end

  test "should get index" do
    get depots_url
    assert_response :success
  end

  test "should get new" do
    get new_depot_url
    assert_response :success
  end

  test "should create depot" do
    assert_difference('Depot.count') do
      post depots_url, params: { depot: { active: @depot.active, company_id: @depot.company_id, name: @depot.name, stock_count: @depot.stock_count } }
    end

    assert_redirected_to depot_url(Depot.last)
  end

  test "should show depot" do
    get depot_url(@depot)
    assert_response :success
  end

  test "should get edit" do
    get edit_depot_url(@depot)
    assert_response :success
  end

  test "should update depot" do
    patch depot_url(@depot), params: { depot: { active: @depot.active, company_id: @depot.company_id, name: @depot.name, stock_count: @depot.stock_count } }
    assert_redirected_to depot_url(@depot)
  end

  test "should destroy depot" do
    assert_difference('Depot.count', -1) do
      delete depot_url(@depot)
    end

    assert_redirected_to depots_url
  end
end
