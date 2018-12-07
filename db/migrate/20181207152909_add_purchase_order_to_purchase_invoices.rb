class AddPurchaseOrderToPurchaseInvoices < ActiveRecord::Migration[5.2]
  def change
    add_reference :purchase_invoices, :purchase_order, foreign_key: true
  end
end
