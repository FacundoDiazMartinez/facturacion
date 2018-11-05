require 'test_helper'

class SuppliersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @supplier = suppliers(:one)
  end

  test "should get index" do
    get suppliers_url
    assert_response :success
  end

  test "should get new" do
    get new_supplier_url
    assert_response :success
  end

  test "should create supplier" do
    assert_difference('Supplier.count') do
      post suppliers_url, params: { supplier: { active: @supplier.active, address: @supplier.address, cbu: @supplier.cbu, company_id: @supplier.company_id, document_number: @supplier.document_number, document_type: @supplier.document_type, email: @supplier.email, mobile_phone: @supplier.mobile_phone, name: @supplier.name, phone: @supplier.phone } }
    end

    assert_redirected_to supplier_url(Supplier.last)
  end

  test "should show supplier" do
    get supplier_url(@supplier)
    assert_response :success
  end

  test "should get edit" do
    get edit_supplier_url(@supplier)
    assert_response :success
  end

  test "should update supplier" do
    patch supplier_url(@supplier), params: { supplier: { active: @supplier.active, address: @supplier.address, cbu: @supplier.cbu, company_id: @supplier.company_id, document_number: @supplier.document_number, document_type: @supplier.document_type, email: @supplier.email, mobile_phone: @supplier.mobile_phone, name: @supplier.name, phone: @supplier.phone } }
    assert_redirected_to supplier_url(@supplier)
  end

  test "should destroy supplier" do
    assert_difference('Supplier.count', -1) do
      delete supplier_url(@supplier)
    end

    assert_redirected_to suppliers_url
  end
end
