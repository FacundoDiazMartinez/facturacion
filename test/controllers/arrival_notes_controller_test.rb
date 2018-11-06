require 'test_helper'

class ArrivalNotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @arrival_note = arrival_notes(:one)
  end

  test "should get index" do
    get arrival_notes_url
    assert_response :success
  end

  test "should get new" do
    get new_arrival_note_url
    assert_response :success
  end

  test "should create arrival_note" do
    assert_difference('ArrivalNote.count') do
      post arrival_notes_url, params: { arrival_note: { active: @arrival_note.active, company_id: @arrival_note.company_id, purchase_order_id: @arrival_note.purchase_order_id, state: @arrival_note.state, user_id: @arrival_note.user_id } }
    end

    assert_redirected_to arrival_note_url(ArrivalNote.last)
  end

  test "should show arrival_note" do
    get arrival_note_url(@arrival_note)
    assert_response :success
  end

  test "should get edit" do
    get edit_arrival_note_url(@arrival_note)
    assert_response :success
  end

  test "should update arrival_note" do
    patch arrival_note_url(@arrival_note), params: { arrival_note: { active: @arrival_note.active, company_id: @arrival_note.company_id, purchase_order_id: @arrival_note.purchase_order_id, state: @arrival_note.state, user_id: @arrival_note.user_id } }
    assert_redirected_to arrival_note_url(@arrival_note)
  end

  test "should destroy arrival_note" do
    assert_difference('ArrivalNote.count', -1) do
      delete arrival_note_url(@arrival_note)
    end

    assert_redirected_to arrival_notes_url
  end
end
