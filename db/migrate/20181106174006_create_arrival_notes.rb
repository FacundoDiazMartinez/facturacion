class CreateArrivalNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :arrival_notes do |t|
      t.references :company, foreign_key: true
      t.references :purchase_order, foreign_key: true
      t.references :user, foreign_key: true
      t.boolean :active, null: false
      t.string :state, null: false, default: "Pendiente"

      t.timestamps
    end
  end
end
