class AddPercepToPurchaseInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_invoices, :percep, :decimal, precision: 10, scale: 2, null: false, default: 0
    change_column :purchase_invoices, :net_amount, :decimal, precision: 10, scale: 2, null: false, default: 0
    change_column :purchase_invoices, :iva_amount, :decimal, precision: 10, scale: 2, null: false, default: 0
    change_column :purchase_invoices, :imp_op_ex, :decimal, precision: 10, scale: 2, null: false, default: 0
    change_column :purchase_invoices, :total, :decimal, precision: 10, scale: 2, null: false, default: 0
    remove_column :purchase_invoices, :iva_aliquot
  end
end
