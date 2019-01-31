require "application_system_test_case"

class CashPaymentsTest < ApplicationSystemTestCase
  setup do
    @cash_payment = cash_payments(:one)
  end

  test "visiting the index" do
    visit cash_payments_url
    assert_selector "h1", text: "Cash Payments"
  end

  test "creating a Cash payment" do
    visit cash_payments_url
    click_on "New Cash Payment"

    click_on "Create Cash payment"

    assert_text "Cash payment was successfully created"
    click_on "Back"
  end

  test "updating a Cash payment" do
    visit cash_payments_url
    click_on "Edit", match: :first

    click_on "Update Cash payment"

    assert_text "Cash payment was successfully updated"
    click_on "Back"
  end

  test "destroying a Cash payment" do
    visit cash_payments_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Cash payment was successfully destroyed"
  end
end
