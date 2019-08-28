class AddBaseImponibleToInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :base_imponible, :decimal, precision: 8, scale: 2, default: 0
    add_column :invoices, :total_tributos, :decimal, precision: 8, scale: 2, default: 0
  end
end
