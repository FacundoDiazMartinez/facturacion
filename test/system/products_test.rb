require "application_system_test_case"

class ProductsTest < ApplicationSystemTestCase
  setup do
    @product = products(:one)
  end

  test "visiting the index" do
    visit products_url
    assert_selector "h1", text: "Products"
  end

  test "creating a Product" do
    visit products_url
    click_on "New Product"

    fill_in "Active", with: @product.active
    fill_in "Code", with: @product.code
    fill_in "List Price", with: @product.list_price
    fill_in "Measurement Unit", with: @product.measurement_unit
    fill_in "Name", with: @product.name
    fill_in "Net Price", with: @product.net_price
    fill_in "Photo", with: @product.photo
    fill_in "Price", with: @product.price
    fill_in "Product Category", with: @product.product_category_id
    click_on "Create Product"

    assert_text "Product was successfully created"
    click_on "Back"
  end

  test "updating a Product" do
    visit products_url
    click_on "Edit", match: :first

    fill_in "Active", with: @product.active
    fill_in "Code", with: @product.code
    fill_in "List Price", with: @product.list_price
    fill_in "Measurement Unit", with: @product.measurement_unit
    fill_in "Name", with: @product.name
    fill_in "Net Price", with: @product.net_price
    fill_in "Photo", with: @product.photo
    fill_in "Price", with: @product.price
    fill_in "Product Category", with: @product.product_category_id
    click_on "Update Product"

    assert_text "Product was successfully updated"
    click_on "Back"
  end

  test "destroying a Product" do
    visit products_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Product was successfully destroyed"
  end
end
