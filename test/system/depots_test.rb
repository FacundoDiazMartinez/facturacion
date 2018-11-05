require "application_system_test_case"

class DepotsTest < ApplicationSystemTestCase
  setup do
    @depot = depots(:one)
  end

  test "visiting the index" do
    visit depots_url
    assert_selector "h1", text: "Depots"
  end

  test "creating a Depot" do
    visit depots_url
    click_on "New Depot"

    fill_in "Active", with: @depot.active
    fill_in "Company", with: @depot.company_id
    fill_in "Name", with: @depot.name
    fill_in "Stock Count", with: @depot.stock_count
    click_on "Create Depot"

    assert_text "Depot was successfully created"
    click_on "Back"
  end

  test "updating a Depot" do
    visit depots_url
    click_on "Edit", match: :first

    fill_in "Active", with: @depot.active
    fill_in "Company", with: @depot.company_id
    fill_in "Name", with: @depot.name
    fill_in "Stock Count", with: @depot.stock_count
    click_on "Update Depot"

    assert_text "Depot was successfully updated"
    click_on "Back"
  end

  test "destroying a Depot" do
    visit depots_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Depot was successfully destroyed"
  end
end
