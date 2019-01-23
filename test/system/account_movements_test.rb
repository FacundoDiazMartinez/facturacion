require "application_system_test_case"

class AccountMovementsTest < ApplicationSystemTestCase
  setup do
    @account_movement = account_movements(:one)
  end

  test "visiting the index" do
    visit account_movements_url
    assert_selector "h1", text: "Account Movements"
  end

  test "creating a Account movement" do
    visit account_movements_url
    click_on "New Account Movement"

    click_on "Create Account movement"

    assert_text "Account movement was successfully created"
    click_on "Back"
  end

  test "updating a Account movement" do
    visit account_movements_url
    click_on "Edit", match: :first

    click_on "Update Account movement"

    assert_text "Account movement was successfully updated"
    click_on "Back"
  end

  test "destroying a Account movement" do
    visit account_movements_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Account movement was successfully destroyed"
  end
end
