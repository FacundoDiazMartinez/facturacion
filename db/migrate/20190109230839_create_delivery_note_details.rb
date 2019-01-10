class CreateDeliveryNoteDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :delivery_note_details do |t|
      t.references :delivery_note, foreign_key: true
      t.references :product, foreign_key: true
      t.references :depot, foreign_key: true
      t.float :quantity, null: false
      t.string :observation
      t.boolean :active, null: false, default: true
      t.boolean :cumpliment, null: false, default: true

      t.timestamps
    end

    add_column :delivery_notes, :date, :date, null: false, default: -> { 'CURRENT_DATE' }
    add_column :delivery_notes, :generated_by, :string, null: false, default: "system"
  end
end
