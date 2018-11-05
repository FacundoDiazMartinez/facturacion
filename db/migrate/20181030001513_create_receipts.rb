class CreateReceipts < ActiveRecord::Migration[5.2]
  def change
    create_table :receipts do |t|
      t.references :invoice, foreign_key: true
      t.boolean :active, null: false, default: true
      t.float :total, null: false, default: 0.0
      t.date :date, null: false
      t.string :observation
      t.string :cbte_tipo, null: false, default: "01"
      t.references :company, foreign_key: true

      t.timestamps
    end
  end
end
