class AddDepotToInvoiceDetails < ActiveRecord::Migration[5.2]
  def change
    add_reference :invoice_details, :depot, foreign_key: true
  end
end
