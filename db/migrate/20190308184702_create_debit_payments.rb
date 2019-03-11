class CreateDebitPayments < ActiveRecord::Migration[5.2]
  def change
    create_table :debit_payments do |t|
      t.references :bank, foreign_key: true
      t.references :payment, foreign_key: true
      t.float :total, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end
