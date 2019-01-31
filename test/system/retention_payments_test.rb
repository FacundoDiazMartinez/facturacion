require "application_system_test_case"

class RetentionPaymentsTest < ApplicationSystemTestCase
  setup do
    @retention_payment = retention_payments(:one)
  end

  test "visiting the index" do
    visit retention_payments_url
    assert_selector "h1", text: "Retention Payments"
  end

  test "creating a Retention payment" do
    visit retention_payments_url
    click_on "New Retention Payment"

    click_on "Create Retention payment"

    assert_text "Retention payment was successfully created"
    click_on "Back"
  end

  test "updating a Retention payment" do
    visit retention_payments_url
    click_on "Edit", match: :first

    click_on "Update Retention payment"

    assert_text "Retention payment was successfully updated"
    click_on "Back"
  end

  test "destroying a Retention payment" do
    visit retention_payments_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Retention payment was successfully destroyed"
  end
end
