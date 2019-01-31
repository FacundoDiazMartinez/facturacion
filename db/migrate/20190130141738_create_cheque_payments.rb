class CreateChequePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :cheque_payments do |t|
      t.string :state, null: false, default: "No cobrado"
      t.date :expiration, null: false, default: -> { "CURRENT_DATE" }
      t.float :total, null: false, default: 0.0
      t.text :observation
      t.boolean :active, null: false, default: true
      t.string :origin, null: false, default: "Propio"
      t.string :entity, null: false
      t.string :number, null: false
      t.references :payment, foreign_key: true

      t.timestamps
    end
  end
end
