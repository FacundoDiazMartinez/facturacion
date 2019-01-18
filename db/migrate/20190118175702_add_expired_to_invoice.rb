class AddExpiredToInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :expired, :boolean, default: false
  end
end
