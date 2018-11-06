require 'test_helper'

class DeliveryNotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @delivery_note = delivery_notes(:one)
  end

  test "should get index" do
    get delivery_notes_url
    assert_response :success
  end

  test "should get new" do
    get new_delivery_note_url
    assert_response :success
  end

  test "should create delivery_note" do
    assert_difference('DeliveryNote.count') do
      post delivery_notes_url, params: { delivery_note: { active: @delivery_note.active, client_id: @delivery_note.client_id, company_id: @delivery_note.company_id, invoice_id: @delivery_note.invoice_id, state: @delivery_note.state, user_id: @delivery_note.user_id } }
    end

    assert_redirected_to delivery_note_url(DeliveryNote.last)
  end

  test "should show delivery_note" do
    get delivery_note_url(@delivery_note)
    assert_response :success
  end

  test "should get edit" do
    get edit_delivery_note_url(@delivery_note)
    assert_response :success
  end

  test "should update delivery_note" do
    patch delivery_note_url(@delivery_note), params: { delivery_note: { active: @delivery_note.active, client_id: @delivery_note.client_id, company_id: @delivery_note.company_id, invoice_id: @delivery_note.invoice_id, state: @delivery_note.state, user_id: @delivery_note.user_id } }
    assert_redirected_to delivery_note_url(@delivery_note)
  end

  test "should destroy delivery_note" do
    assert_difference('DeliveryNote.count', -1) do
      delete delivery_note_url(@delivery_note)
    end

    assert_redirected_to delivery_notes_url
  end
end
