class RemoveReceiptFromInvoice < ActiveRecord::Migration[5.2]
  def change
  	remove_column :receipts, :invoice_id
  end
end
