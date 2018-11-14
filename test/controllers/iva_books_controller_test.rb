require 'test_helper'

class IvaBooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @iva_book = iva_books(:one)
  end

  test "should get index" do
    get iva_books_url
    assert_response :success
  end

  test "should get new" do
    get new_iva_book_url
    assert_response :success
  end

  test "should create iva_book" do
    assert_difference('IvaBook.count') do
      post iva_books_url, params: { iva_book: { date: @iva_book.date, invoice_id: @iva_book.invoice_id, iva_amount: @iva_book.iva_amount, net_amount: @iva_book.net_amount, purchase_invoice_id: @iva_book.purchase_invoice_id, tipo: @iva_book.tipo, total: @iva_book.total } }
    end

    assert_redirected_to iva_book_url(IvaBook.last)
  end

  test "should show iva_book" do
    get iva_book_url(@iva_book)
    assert_response :success
  end

  test "should get edit" do
    get edit_iva_book_url(@iva_book)
    assert_response :success
  end

  test "should update iva_book" do
    patch iva_book_url(@iva_book), params: { iva_book: { date: @iva_book.date, invoice_id: @iva_book.invoice_id, iva_amount: @iva_book.iva_amount, net_amount: @iva_book.net_amount, purchase_invoice_id: @iva_book.purchase_invoice_id, tipo: @iva_book.tipo, total: @iva_book.total } }
    assert_redirected_to iva_book_url(@iva_book)
  end

  test "should destroy iva_book" do
    assert_difference('IvaBook.count', -1) do
      delete iva_book_url(@iva_book)
    end

    assert_redirected_to iva_books_url
  end
end
