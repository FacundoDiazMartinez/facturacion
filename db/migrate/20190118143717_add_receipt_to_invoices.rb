class AddReceiptToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_reference :invoices, :receipt, foreign_key: true
  end
end
