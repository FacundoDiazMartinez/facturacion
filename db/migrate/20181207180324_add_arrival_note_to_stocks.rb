class AddArrivalNoteToStocks < ActiveRecord::Migration[5.2]
  def change
    add_reference :stocks, :arrival_note_detail, foreign_key: true
  end
end
