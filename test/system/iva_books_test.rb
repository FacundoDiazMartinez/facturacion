require "application_system_test_case"

class IvaBooksTest < ApplicationSystemTestCase
  setup do
    @iva_book = iva_books(:one)
  end

  test "visiting the index" do
    visit iva_books_url
    assert_selector "h1", text: "Iva Books"
  end

  test "creating a Iva book" do
    visit iva_books_url
    click_on "New Iva Book"

    fill_in "Date", with: @iva_book.date
    fill_in "Invoice", with: @iva_book.invoice_id
    fill_in "Iva Amount", with: @iva_book.iva_amount
    fill_in "Net Amount", with: @iva_book.net_amount
    fill_in "Purchase Invoice", with: @iva_book.purchase_invoice_id
    fill_in "Tipo", with: @iva_book.tipo
    fill_in "Total", with: @iva_book.total
    click_on "Create Iva book"

    assert_text "Iva book was successfully created"
    click_on "Back"
  end

  test "updating a Iva book" do
    visit iva_books_url
    click_on "Edit", match: :first

    fill_in "Date", with: @iva_book.date
    fill_in "Invoice", with: @iva_book.invoice_id
    fill_in "Iva Amount", with: @iva_book.iva_amount
    fill_in "Net Amount", with: @iva_book.net_amount
    fill_in "Purchase Invoice", with: @iva_book.purchase_invoice_id
    fill_in "Tipo", with: @iva_book.tipo
    fill_in "Total", with: @iva_book.total
    click_on "Update Iva book"

    assert_text "Iva book was successfully updated"
    click_on "Back"
  end

  test "destroying a Iva book" do
    visit iva_books_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Iva book was successfully destroyed"
  end
end
