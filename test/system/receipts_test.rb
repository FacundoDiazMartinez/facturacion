require "application_system_test_case"

class ReceiptsTest < ApplicationSystemTestCase
  setup do
    @receipt = receipts(:one)
  end

  test "visiting the index" do
    visit receipts_url
    assert_selector "h1", text: "Receipts"
  end

  test "creating a Receipt" do
    visit receipts_url
    click_on "New Receipt"

    fill_in "Active", with: @receipt.active
    fill_in "Client", with: @receipt.client_id
    fill_in "Company", with: @receipt.company_id
    fill_in "Date", with: @receipt.date
    fill_in "Invoice", with: @receipt.invoice_id
    fill_in "Observation", with: @receipt.observation
    fill_in "Total", with: @receipt.total
    click_on "Create Receipt"

    assert_text "Receipt was successfully created"
    click_on "Back"
  end

  test "updating a Receipt" do
    visit receipts_url
    click_on "Edit", match: :first

    fill_in "Active", with: @receipt.active
    fill_in "Client", with: @receipt.client_id
    fill_in "Company", with: @receipt.company_id
    fill_in "Date", with: @receipt.date
    fill_in "Invoice", with: @receipt.invoice_id
    fill_in "Observation", with: @receipt.observation
    fill_in "Total", with: @receipt.total
    click_on "Update Receipt"

    assert_text "Receipt was successfully updated"
    click_on "Back"
  end

  test "destroying a Receipt" do
    visit receipts_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Receipt was successfully destroyed"
  end
end
