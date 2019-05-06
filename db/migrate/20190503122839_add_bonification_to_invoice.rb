class AddBonificationToInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :bonification, :float, null: false, default: 0.0
  end
end
