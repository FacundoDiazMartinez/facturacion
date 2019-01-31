require "application_system_test_case"

class CardPaymentsTest < ApplicationSystemTestCase
  setup do
    @card_payment = card_payments(:one)
  end

  test "visiting the index" do
    visit card_payments_url
    assert_selector "h1", text: "Card Payments"
  end

  test "creating a Card payment" do
    visit card_payments_url
    click_on "New Card Payment"

    click_on "Create Card payment"

    assert_text "Card payment was successfully created"
    click_on "Back"
  end

  test "updating a Card payment" do
    visit card_payments_url
    click_on "Edit", match: :first

    click_on "Update Card payment"

    assert_text "Card payment was successfully updated"
    click_on "Back"
  end

  test "destroying a Card payment" do
    visit card_payments_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Card payment was successfully destroyed"
  end
end
