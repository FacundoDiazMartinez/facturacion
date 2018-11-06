require "application_system_test_case"

class DeliveryNotesTest < ApplicationSystemTestCase
  setup do
    @delivery_note = delivery_notes(:one)
  end

  test "visiting the index" do
    visit delivery_notes_url
    assert_selector "h1", text: "Delivery Notes"
  end

  test "creating a Delivery note" do
    visit delivery_notes_url
    click_on "New Delivery Note"

    fill_in "Active", with: @delivery_note.active
    fill_in "Client", with: @delivery_note.client_id
    fill_in "Company", with: @delivery_note.company_id
    fill_in "Invoice", with: @delivery_note.invoice_id
    fill_in "State", with: @delivery_note.state
    fill_in "User", with: @delivery_note.user_id
    click_on "Create Delivery note"

    assert_text "Delivery note was successfully created"
    click_on "Back"
  end

  test "updating a Delivery note" do
    visit delivery_notes_url
    click_on "Edit", match: :first

    fill_in "Active", with: @delivery_note.active
    fill_in "Client", with: @delivery_note.client_id
    fill_in "Company", with: @delivery_note.company_id
    fill_in "Invoice", with: @delivery_note.invoice_id
    fill_in "State", with: @delivery_note.state
    fill_in "User", with: @delivery_note.user_id
    click_on "Update Delivery note"

    assert_text "Delivery note was successfully updated"
    click_on "Back"
  end

  test "destroying a Delivery note" do
    visit delivery_notes_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Delivery note was successfully destroyed"
  end
end
