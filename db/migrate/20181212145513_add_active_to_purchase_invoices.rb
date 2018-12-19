class AddActiveToPurchaseInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_invoices, :active, :boolean, default: true
  end
end
