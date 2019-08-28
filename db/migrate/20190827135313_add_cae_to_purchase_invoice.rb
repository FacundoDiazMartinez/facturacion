class AddCaeToPurchaseInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_invoices, :cae, :string
  end
end
