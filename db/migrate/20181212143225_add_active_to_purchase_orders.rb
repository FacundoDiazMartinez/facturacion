class AddActiveToPurchaseOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :active, :boolean, default: true
  end
end
