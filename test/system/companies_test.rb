require "application_system_test_case"

class CompaniesTest < ApplicationSystemTestCase
  setup do
    @company = companies(:one)
  end

  test "visiting the index" do
    visit companies_url
    assert_selector "h1", text: "Companies"
  end

  test "creating a Company" do
    visit companies_url
    click_on "New Company"

    fill_in "Activity Init Date", with: @company.activity_init_date
    fill_in "Cbu", with: @company.cbu
    fill_in "City", with: @company.city
    fill_in "Code", with: @company.code
    fill_in "Concepto", with: @company.concepto
    fill_in "Contact Number", with: @company.contact_number
    fill_in "Country", with: @company.country
    fill_in "Cuit", with: @company.cuit
    fill_in "Email", with: @company.email
    fill_in "Environment", with: @company.environment
    fill_in "Iva Cond", with: @company.iva_cond
    fill_in "Location", with: @company.location
    fill_in "Logo", with: @company.logo
    fill_in "Moneda", with: @company.moneda
    fill_in "Name", with: @company.name
    fill_in "Paid", with: @company.paid
    fill_in "Postal Code", with: @company.postal_code
    fill_in "Society Name", with: @company.society_name
    fill_in "Suscription Type", with: @company.suscription_type
    click_on "Create Company"

    assert_text "Company was successfully created"
    click_on "Back"
  end

  test "updating a Company" do
    visit companies_url
    click_on "Edit", match: :first

    fill_in "Activity Init Date", with: @company.activity_init_date
    fill_in "Cbu", with: @company.cbu
    fill_in "City", with: @company.city
    fill_in "Code", with: @company.code
    fill_in "Concepto", with: @company.concepto
    fill_in "Contact Number", with: @company.contact_number
    fill_in "Country", with: @company.country
    fill_in "Cuit", with: @company.cuit
    fill_in "Email", with: @company.email
    fill_in "Environment", with: @company.environment
    fill_in "Iva Cond", with: @company.iva_cond
    fill_in "Location", with: @company.location
    fill_in "Logo", with: @company.logo
    fill_in "Moneda", with: @company.moneda
    fill_in "Name", with: @company.name
    fill_in "Paid", with: @company.paid
    fill_in "Postal Code", with: @company.postal_code
    fill_in "Society Name", with: @company.society_name
    fill_in "Suscription Type", with: @company.suscription_type
    click_on "Update Company"

    assert_text "Company was successfully updated"
    click_on "Back"
  end

  test "destroying a Company" do
    visit companies_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Company was successfully destroyed"
  end
end
