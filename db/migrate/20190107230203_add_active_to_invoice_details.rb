class AddActiveToInvoiceDetails < ActiveRecord::Migration[5.2]
  def change
    add_column :invoice_details, :active, :boolean, null: false, default: true
  end
end
