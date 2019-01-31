class CreateCardPayments < ActiveRecord::Migration[5.2]
  def change
    create_table :card_payments do |t|
      t.references :payment, foreign_key: true
      t.references :credit_card, foreign_key: true
      t.float :subtotal, null: false, default: 0.0
      t.integer :installments, null: false, default: 1
      t.float :interest_rate_percentage, null:false, default: 0.0
      t.float :interest_rate_amount, null:false, default: 0.0
      t.float :total, null: false, default: 0.0
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
