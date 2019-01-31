class CreateCashPayments < ActiveRecord::Migration[5.2]
  def change
    create_table :cash_payments do |t|
      t.float :total, null: false, default: 0.0
      t.references :payment, foreign_key: true
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
