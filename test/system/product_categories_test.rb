require "application_system_test_case"

class ProductCategoriesTest < ApplicationSystemTestCase
  setup do
    @product_category = product_categories(:one)
  end

  test "visiting the index" do
    visit product_categories_url
    assert_selector "h1", text: "Product Categories"
  end

  test "creating a Product category" do
    visit product_categories_url
    click_on "New Product Category"

    fill_in "Active", with: @product_category.active
    fill_in "Company", with: @product_category.company_id
    fill_in "Iva Aliquot", with: @product_category.iva_aliquot
    fill_in "Name", with: @product_category.name
    fill_in "Products Count", with: @product_category.products_count
    click_on "Create Product category"

    assert_text "Product category was successfully created"
    click_on "Back"
  end

  test "updating a Product category" do
    visit product_categories_url
    click_on "Edit", match: :first

    fill_in "Active", with: @product_category.active
    fill_in "Company", with: @product_category.company_id
    fill_in "Iva Aliquot", with: @product_category.iva_aliquot
    fill_in "Name", with: @product_category.name
    fill_in "Products Count", with: @product_category.products_count
    click_on "Update Product category"

    assert_text "Product category was successfully updated"
    click_on "Back"
  end

  test "destroying a Product category" do
    visit product_categories_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Product category was successfully destroyed"
  end
end
