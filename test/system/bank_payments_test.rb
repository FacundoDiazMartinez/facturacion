require "application_system_test_case"

class BankPaymentsTest < ApplicationSystemTestCase
  setup do
    @bank_payment = bank_payments(:one)
  end

  test "visiting the index" do
    visit bank_payments_url
    assert_selector "h1", text: "Bank Payments"
  end

  test "creating a Bank payment" do
    visit bank_payments_url
    click_on "New Bank Payment"

    click_on "Create Bank payment"

    assert_text "Bank payment was successfully created"
    click_on "Back"
  end

  test "updating a Bank payment" do
    visit bank_payments_url
    click_on "Edit", match: :first

    click_on "Update Bank payment"

    assert_text "Bank payment was successfully updated"
    click_on "Back"
  end

  test "destroying a Bank payment" do
    visit bank_payments_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Bank payment was successfully destroyed"
  end
end
