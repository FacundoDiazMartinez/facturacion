require "application_system_test_case"

class InvoicesTest < ApplicationSystemTestCase
  setup do
    @invoice = invoices(:one)
  end

  test "visiting the index" do
    visit invoices_url
    assert_selector "h1", text: "Invoices"
  end

  test "creating a Invoice" do
    visit invoices_url
    click_on "New Invoice"

    fill_in "Active", with: @invoice.active
    fill_in "Authorized On", with: @invoice.authorized_on
    fill_in "Cae", with: @invoice.cae
    fill_in "Cae Due Date", with: @invoice.cae_due_date
    fill_in "Cbte Desde", with: @invoice.cbte_desde
    fill_in "Cbte Fch", with: @invoice.cbte_fch
    fill_in "Cbte Hasta", with: @invoice.cbte_hasta
    fill_in "Cbte Tipo", with: @invoice.cbte_tipo
    fill_in "Client", with: @invoice.client_id
    fill_in "Comp Number", with: @invoice.comp_number
    fill_in "Company", with: @invoice.company_id
    fill_in "Concepto", with: @invoice.concepto
    fill_in "Date", with: @invoice.date
    fill_in "Header Result", with: @invoice.header_result
    fill_in "Imp Iva", with: @invoice.imp_iva
    fill_in "Imp Neto", with: @invoice.imp_neto
    fill_in "Imp Op Ex", with: @invoice.imp_op_ex
    fill_in "Imp Tot Conc", with: @invoice.imp_tot_conc
    fill_in "Imp Total", with: @invoice.imp_total
    fill_in "Imp Trib", with: @invoice.imp_trib
    fill_in "Iva Cond", with: @invoice.iva_cond
    fill_in "Iva Importe", with: @invoice.iva_importe
    fill_in "Sale Point", with: @invoice.sale_point_id
    fill_in "State", with: @invoice.state
    fill_in "Total", with: @invoice.total
    fill_in "Total Pay", with: @invoice.total_pay
    fill_in "User", with: @invoice.user_id
    click_on "Create Invoice"

    assert_text "Invoice was successfully created"
    click_on "Back"
  end

  test "updating a Invoice" do
    visit invoices_url
    click_on "Edit", match: :first

    fill_in "Active", with: @invoice.active
    fill_in "Authorized On", with: @invoice.authorized_on
    fill_in "Cae", with: @invoice.cae
    fill_in "Cae Due Date", with: @invoice.cae_due_date
    fill_in "Cbte Desde", with: @invoice.cbte_desde
    fill_in "Cbte Fch", with: @invoice.cbte_fch
    fill_in "Cbte Hasta", with: @invoice.cbte_hasta
    fill_in "Cbte Tipo", with: @invoice.cbte_tipo
    fill_in "Client", with: @invoice.client_id
    fill_in "Comp Number", with: @invoice.comp_number
    fill_in "Company", with: @invoice.company_id
    fill_in "Concepto", with: @invoice.concepto
    fill_in "Date", with: @invoice.date
    fill_in "Header Result", with: @invoice.header_result
    fill_in "Imp Iva", with: @invoice.imp_iva
    fill_in "Imp Neto", with: @invoice.imp_neto
    fill_in "Imp Op Ex", with: @invoice.imp_op_ex
    fill_in "Imp Tot Conc", with: @invoice.imp_tot_conc
    fill_in "Imp Total", with: @invoice.imp_total
    fill_in "Imp Trib", with: @invoice.imp_trib
    fill_in "Iva Cond", with: @invoice.iva_cond
    fill_in "Iva Importe", with: @invoice.iva_importe
    fill_in "Sale Point", with: @invoice.sale_point_id
    fill_in "State", with: @invoice.state
    fill_in "Total", with: @invoice.total
    fill_in "Total Pay", with: @invoice.total_pay
    fill_in "User", with: @invoice.user_id
    click_on "Update Invoice"

    assert_text "Invoice was successfully updated"
    click_on "Back"
  end

  test "destroying a Invoice" do
    visit invoices_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Invoice was successfully destroyed"
  end
end
