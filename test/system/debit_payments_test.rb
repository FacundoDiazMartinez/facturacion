require "application_system_test_case"

class DebitPaymentsTest < ApplicationSystemTestCase
  setup do
    @debit_payment = debit_payments(:one)
  end

  test "visiting the index" do
    visit debit_payments_url
    assert_selector "h1", text: "Debit Payments"
  end

  test "creating a Debit payment" do
    visit debit_payments_url
    click_on "New Debit Payment"

    click_on "Create Debit payment"

    assert_text "Debit payment was successfully created"
    click_on "Back"
  end

  test "updating a Debit payment" do
    visit debit_payments_url
    click_on "Edit", match: :first

    click_on "Update Debit payment"

    assert_text "Debit payment was successfully updated"
    click_on "Back"
  end

  test "destroying a Debit payment" do
    visit debit_payments_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Debit payment was successfully destroyed"
  end
end
