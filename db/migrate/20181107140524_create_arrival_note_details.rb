class CreateArrivalNoteDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :arrival_note_details do |t|
      t.references :arrival_note, foreign_key: true
      t.references :product, foreign_key: true
      t.string :quantity
      t.boolean :cumpliment
      t.string :observation

      t.timestamps
    end
  end
end
