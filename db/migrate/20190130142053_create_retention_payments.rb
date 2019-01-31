class CreateRetentionPayments < ActiveRecord::Migration[5.2]
  def change
    create_table :retention_payments do |t|
      t.references :payment, foreign_key: true
      t.boolean :active, null: false, default: true
      t.float :total, null: false, default: 0.0
      t.string :number, null: false
      t.text :observation
      t.string :tribute, null: false

      t.timestamps
    end
  end
end
