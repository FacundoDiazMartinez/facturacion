class ChangeQuantityFromArrivalNoteDetails < ActiveRecord::Migration[5.2]
  def change
  	remove_column :arrival_note_details, :quantity
  	add_column :arrival_note_details, :quantity, :float, null: false, default: 0.0
  end
end
