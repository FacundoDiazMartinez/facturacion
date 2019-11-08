class AddOnAccountToInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :on_account, :boolean, default: false, null: false
  end
end
