class AddIvaAliquotToPurchaseInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_invoices, :iva_aliquot, :string
  end
end
