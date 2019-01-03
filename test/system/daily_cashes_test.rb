require "application_system_test_case"

class DailyCashesTest < ApplicationSystemTestCase
  setup do
    @daily_cash = daily_cashes(:one)
  end

  test "visiting the index" do
    visit daily_cashes_url
    assert_selector "h1", text: "Daily Cashes"
  end

  test "creating a Daily cash" do
    visit daily_cashes_url
    click_on "New Daily Cash"

    fill_in "Company", with: @daily_cash.company_id
    fill_in "Final amount", with: @daily_cash.final_amount
    fill_in "Initial amount", with: @daily_cash.initial_amount
    fill_in "State", with: @daily_cash.state
    fill_in "User", with: @daily_cash.user_id
    click_on "Create Daily cash"

    assert_text "Daily cash was successfully created"
    click_on "Back"
  end

  test "updating a Daily cash" do
    visit daily_cashes_url
    click_on "Edit", match: :first

    fill_in "Company", with: @daily_cash.company_id
    fill_in "Final amount", with: @daily_cash.final_amount
    fill_in "Initial amount", with: @daily_cash.initial_amount
    fill_in "State", with: @daily_cash.state
    fill_in "User", with: @daily_cash.user_id
    click_on "Update Daily cash"

    assert_text "Daily cash was successfully updated"
    click_on "Back"
  end

  test "destroying a Daily cash" do
    visit daily_cashes_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Daily cash was successfully destroyed"
  end
end
