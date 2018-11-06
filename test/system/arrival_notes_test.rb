require "application_system_test_case"

class ArrivalNotesTest < ApplicationSystemTestCase
  setup do
    @arrival_note = arrival_notes(:one)
  end

  test "visiting the index" do
    visit arrival_notes_url
    assert_selector "h1", text: "Arrival Notes"
  end

  test "creating a Arrival note" do
    visit arrival_notes_url
    click_on "New Arrival Note"

    fill_in "Active", with: @arrival_note.active
    fill_in "Company", with: @arrival_note.company_id
    fill_in "Purchase Order", with: @arrival_note.purchase_order_id
    fill_in "State", with: @arrival_note.state
    fill_in "User", with: @arrival_note.user_id
    click_on "Create Arrival note"

    assert_text "Arrival note was successfully created"
    click_on "Back"
  end

  test "updating a Arrival note" do
    visit arrival_notes_url
    click_on "Edit", match: :first

    fill_in "Active", with: @arrival_note.active
    fill_in "Company", with: @arrival_note.company_id
    fill_in "Purchase Order", with: @arrival_note.purchase_order_id
    fill_in "State", with: @arrival_note.state
    fill_in "User", with: @arrival_note.user_id
    click_on "Update Arrival note"

    assert_text "Arrival note was successfully updated"
    click_on "Back"
  end

  test "destroying a Arrival note" do
    visit arrival_notes_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Arrival note was successfully destroyed"
  end
end
