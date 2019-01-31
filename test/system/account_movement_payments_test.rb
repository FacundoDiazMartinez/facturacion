require "application_system_test_case"

class AccountMovementPaymentsTest < ApplicationSystemTestCase
  setup do
    @account_movement_payment = account_movement_payments(:one)
  end

  test "visiting the index" do
    visit account_movement_payments_url
    assert_selector "h1", text: "Account Movement Payments"
  end

  test "creating a Account movement payment" do
    visit account_movement_payments_url
    click_on "New Account Movement Payment"

    click_on "Create Account movement payment"

    assert_text "Account movement payment was successfully created"
    click_on "Back"
  end

  test "updating a Account movement payment" do
    visit account_movement_payments_url
    click_on "Edit", match: :first

    click_on "Update Account movement payment"

    assert_text "Account movement payment was successfully updated"
    click_on "Back"
  end

  test "destroying a Account movement payment" do
    visit account_movement_payments_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Account movement payment was successfully destroyed"
  end
end
