class CreatePurchaseInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :purchase_invoices do |t|
      t.references :company, foreign_key: true
      t.references :user, foreign_key: true
      t.references :arrival_note, foreign_key: true
      t.integer :number, null: false
      t.references :supplier, foreign_key: true
      t.string :cbte_tipo
      t.float :net_amount, null: false, default: 0.0
      t.float :iva_amount, null: false, default: 0.0
      t.float :imp_op_ex, null: false, default: 0.0
      t.float :total, null: false, default: 0.0

      t.timestamps
    end
  end
end
