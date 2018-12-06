class AddAssociatedInvoiceToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :associated_invoice, :bigint
  end
end
