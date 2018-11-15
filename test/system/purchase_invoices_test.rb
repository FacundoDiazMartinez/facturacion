require "application_system_test_case"

class PurchaseInvoicesTest < ApplicationSystemTestCase
  setup do
    @purchase_invoice = purchase_invoices(:one)
  end

  test "visiting the index" do
    visit purchase_invoices_url
    assert_selector "h1", text: "Purchase Invoices"
  end

  test "creating a Purchase invoice" do
    visit purchase_invoices_url
    click_on "New Purchase Invoice"

    fill_in "Arrival Note", with: @purchase_invoice.arrival_note_id
    fill_in "Cbte Tipo", with: @purchase_invoice.cbte_tipo
    fill_in "Company", with: @purchase_invoice.company_id
    fill_in "Imp Op Ex", with: @purchase_invoice.imp_op_ex
    fill_in "Iva Amount", with: @purchase_invoice.iva_amount
    fill_in "Net Amount", with: @purchase_invoice.net_amount
    fill_in "Number", with: @purchase_invoice.number
    fill_in "State", with: @purchase_invoice.state
    fill_in "Supplier", with: @purchase_invoice.supplier_id
    fill_in "Total", with: @purchase_invoice.total
    fill_in "User", with: @purchase_invoice.user_id
    click_on "Create Purchase invoice"

    assert_text "Purchase invoice was successfully created"
    click_on "Back"
  end

  test "updating a Purchase invoice" do
    visit purchase_invoices_url
    click_on "Edit", match: :first

    fill_in "Arrival Note", with: @purchase_invoice.arrival_note_id
    fill_in "Cbte Tipo", with: @purchase_invoice.cbte_tipo
    fill_in "Company", with: @purchase_invoice.company_id
    fill_in "Imp Op Ex", with: @purchase_invoice.imp_op_ex
    fill_in "Iva Amount", with: @purchase_invoice.iva_amount
    fill_in "Net Amount", with: @purchase_invoice.net_amount
    fill_in "Number", with: @purchase_invoice.number
    fill_in "State", with: @purchase_invoice.state
    fill_in "Supplier", with: @purchase_invoice.supplier_id
    fill_in "Total", with: @purchase_invoice.total
    fill_in "User", with: @purchase_invoice.user_id
    click_on "Update Purchase invoice"

    assert_text "Purchase invoice was successfully updated"
    click_on "Back"
  end

  test "destroying a Purchase invoice" do
    visit purchase_invoices_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Purchase invoice was successfully destroyed"
  end
end
