require 'test_helper'

class PurchaseInvoicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @purchase_invoice = purchase_invoices(:one)
  end

  test "should get index" do
    get purchase_invoices_url
    assert_response :success
  end

  test "should get new" do
    get new_purchase_invoice_url
    assert_response :success
  end

  test "should create purchase_invoice" do
    assert_difference('PurchaseInvoice.count') do
      post purchase_invoices_url, params: { purchase_invoice: { arrival_note_id: @purchase_invoice.arrival_note_id, cbte_tipo: @purchase_invoice.cbte_tipo, company_id: @purchase_invoice.company_id, imp_op_ex: @purchase_invoice.imp_op_ex, iva_amount: @purchase_invoice.iva_amount, net_amount: @purchase_invoice.net_amount, number: @purchase_invoice.number, state: @purchase_invoice.state, supplier_id: @purchase_invoice.supplier_id, total: @purchase_invoice.total, user_id: @purchase_invoice.user_id } }
    end

    assert_redirected_to purchase_invoice_url(PurchaseInvoice.last)
  end

  test "should show purchase_invoice" do
    get purchase_invoice_url(@purchase_invoice)
    assert_response :success
  end

  test "should get edit" do
    get edit_purchase_invoice_url(@purchase_invoice)
    assert_response :success
  end

  test "should update purchase_invoice" do
    patch purchase_invoice_url(@purchase_invoice), params: { purchase_invoice: { arrival_note_id: @purchase_invoice.arrival_note_id, cbte_tipo: @purchase_invoice.cbte_tipo, company_id: @purchase_invoice.company_id, imp_op_ex: @purchase_invoice.imp_op_ex, iva_amount: @purchase_invoice.iva_amount, net_amount: @purchase_invoice.net_amount, number: @purchase_invoice.number, state: @purchase_invoice.state, supplier_id: @purchase_invoice.supplier_id, total: @purchase_invoice.total, user_id: @purchase_invoice.user_id } }
    assert_redirected_to purchase_invoice_url(@purchase_invoice)
  end

  test "should destroy purchase_invoice" do
    assert_difference('PurchaseInvoice.count', -1) do
      delete purchase_invoice_url(@purchase_invoice)
    end

    assert_redirected_to purchase_invoices_url
  end
end
