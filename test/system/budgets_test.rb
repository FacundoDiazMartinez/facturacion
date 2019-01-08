require "application_system_test_case"

class BudgetsTest < ApplicationSystemTestCase
  setup do
    @budget = budgets(:one)
  end

  test "visiting the index" do
    visit budgets_url
    assert_selector "h1", text: "Budgets"
  end

  test "creating a Budget" do
    visit budgets_url
    click_on "New Budget"

    fill_in "Active", with: @budget.active
    fill_in "Client", with: @budget.client_id
    fill_in "Company", with: @budget.company_id
    fill_in "Date", with: @budget.date
    fill_in "Expiration date", with: @budget.expiration_date
    fill_in "Reserv stock", with: @budget.reserv_stock
    fill_in "Total", with: @budget.total
    fill_in "User", with: @budget.user_id
    click_on "Create Budget"

    assert_text "Budget was successfully created"
    click_on "Back"
  end

  test "updating a Budget" do
    visit budgets_url
    click_on "Edit", match: :first

    fill_in "Active", with: @budget.active
    fill_in "Client", with: @budget.client_id
    fill_in "Company", with: @budget.company_id
    fill_in "Date", with: @budget.date
    fill_in "Expiration date", with: @budget.expiration_date
    fill_in "Reserv stock", with: @budget.reserv_stock
    fill_in "Total", with: @budget.total
    fill_in "User", with: @budget.user_id
    click_on "Update Budget"

    assert_text "Budget was successfully updated"
    click_on "Back"
  end

  test "destroying a Budget" do
    visit budgets_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Budget was successfully destroyed"
  end
end
