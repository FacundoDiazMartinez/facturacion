require "application_system_test_case"

class ChequePaymentsTest < ApplicationSystemTestCase
  setup do
    @cheque_payment = cheque_payments(:one)
  end

  test "visiting the index" do
    visit cheque_payments_url
    assert_selector "h1", text: "Cheque Payments"
  end

  test "creating a Cheque payment" do
    visit cheque_payments_url
    click_on "New Cheque Payment"

    click_on "Create Cheque payment"

    assert_text "Cheque payment was successfully created"
    click_on "Back"
  end

  test "updating a Cheque payment" do
    visit cheque_payments_url
    click_on "Edit", match: :first

    click_on "Update Cheque payment"

    assert_text "Cheque payment was successfully updated"
    click_on "Back"
  end

  test "destroying a Cheque payment" do
    visit cheque_payments_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Cheque payment was successfully destroyed"
  end
end
