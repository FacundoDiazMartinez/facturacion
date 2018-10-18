require 'test_helper'

class InvoicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @invoice = invoices(:one)
  end

  test "should get index" do
    get invoices_url
    assert_response :success
  end

  test "should get new" do
    get new_invoice_url
    assert_response :success
  end

  test "should create invoice" do
    assert_difference('Invoice.count') do
      post invoices_url, params: { invoice: { active: @invoice.active, authorized_on: @invoice.authorized_on, cae: @invoice.cae, cae_due_date: @invoice.cae_due_date, cbte_desde: @invoice.cbte_desde, cbte_fch: @invoice.cbte_fch, cbte_hasta: @invoice.cbte_hasta, cbte_tipo: @invoice.cbte_tipo, client_id: @invoice.client_id, comp_number: @invoice.comp_number, company_id: @invoice.company_id, concepto: @invoice.concepto, date: @invoice.date, header_result: @invoice.header_result, imp_iva: @invoice.imp_iva, imp_neto: @invoice.imp_neto, imp_op_ex: @invoice.imp_op_ex, imp_tot_conc: @invoice.imp_tot_conc, imp_total: @invoice.imp_total, imp_trib: @invoice.imp_trib, iva_cond: @invoice.iva_cond, iva_importe: @invoice.iva_importe, sale_point_id: @invoice.sale_point_id, state: @invoice.state, total: @invoice.total, total_pay: @invoice.total_pay, user_id: @invoice.user_id } }
    end

    assert_redirected_to invoice_url(Invoice.last)
  end

  test "should show invoice" do
    get invoice_url(@invoice)
    assert_response :success
  end

  test "should get edit" do
    get edit_invoice_url(@invoice)
    assert_response :success
  end

  test "should update invoice" do
    patch invoice_url(@invoice), params: { invoice: { active: @invoice.active, authorized_on: @invoice.authorized_on, cae: @invoice.cae, cae_due_date: @invoice.cae_due_date, cbte_desde: @invoice.cbte_desde, cbte_fch: @invoice.cbte_fch, cbte_hasta: @invoice.cbte_hasta, cbte_tipo: @invoice.cbte_tipo, client_id: @invoice.client_id, comp_number: @invoice.comp_number, company_id: @invoice.company_id, concepto: @invoice.concepto, date: @invoice.date, header_result: @invoice.header_result, imp_iva: @invoice.imp_iva, imp_neto: @invoice.imp_neto, imp_op_ex: @invoice.imp_op_ex, imp_tot_conc: @invoice.imp_tot_conc, imp_total: @invoice.imp_total, imp_trib: @invoice.imp_trib, iva_cond: @invoice.iva_cond, iva_importe: @invoice.iva_importe, sale_point_id: @invoice.sale_point_id, state: @invoice.state, total: @invoice.total, total_pay: @invoice.total_pay, user_id: @invoice.user_id } }
    assert_redirected_to invoice_url(@invoice)
  end

  test "should destroy invoice" do
    assert_difference('Invoice.count', -1) do
      delete invoice_url(@invoice)
    end

    assert_redirected_to invoices_url
  end
end
