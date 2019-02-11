class CreateAccountPayments < ActiveRecord::Migration[5.2]
  def change
    create_table :account_payments do |t|
      t.float :total, null: false, default: 0.0
      t.boolean :active, null: false, default: true
      t.references :payment, foreign_key: true

      t.timestamps
    end
  end
end
