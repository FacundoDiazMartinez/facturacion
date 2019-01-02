class CreateDailyCashMovements < ActiveRecord::Migration[5.2]
  def change
    create_table :daily_cash_movements do |t|
      t.references :daily_cash, foreign_key: true
      t.string :movement_type, null: false
      t.float :amount, null: false, default: 0.0
      t.bigint :associated_document
      t.string :payment_type

      t.timestamps
    end
  end
end
