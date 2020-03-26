class AddDeliveredToInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :delivered, :boolean, default: false, null: false
  end
end
