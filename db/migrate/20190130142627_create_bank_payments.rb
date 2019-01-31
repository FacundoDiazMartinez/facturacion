class CreateBankPayments < ActiveRecord::Migration[5.2]
  def change
    create_table :bank_payments do |t|
      t.references :bank, foreign_key: true
      t.references :payment, foreign_key: true
      t.float :total, null: false, default: 0.0
      t.string :ticket
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
