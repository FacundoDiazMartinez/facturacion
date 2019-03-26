class ChangeDefaultToInvoiceDetails < ActiveRecord::Migration[5.2]
  def change
  	change_column :invoice_details, :quantity, :float, null: false, default: 0
  end
end
