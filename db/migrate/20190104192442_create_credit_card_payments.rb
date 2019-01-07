class CreateCreditCardPayments < ActiveRecord::Migration[5.2]
  def change
    create_table :credit_card_payments do |t|
      t.references :payment, foreign_key: true
      t.references :credit_card, foreign_key: true
      t.float :amount, null: false, default: 0.0
      t.string :tipo, null: false

      t.timestamps
    end
  end
end
