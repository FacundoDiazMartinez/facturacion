class AddReqQuantityToArrivalNoteDetails < ActiveRecord::Migration[5.2]
  def change
    add_column :arrival_note_details, :req_quantity, :float
    add_column :arrival_note_details, :completed, :boolean, null: false, default: false
  end
end
