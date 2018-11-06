class CreateDeliveryNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :delivery_notes do |t|
      t.references :company, foreign_key: true
      t.references :invoice, foreign_key: true
      t.references :user, foreign_key: true
      t.references :client, foreign_key: true
      t.boolean :active, default: true, null: false
      t.string :state, null: false, default: "Pendiente"

      t.timestamps
    end
  end
end
