class AddDeilveredToPurchaseOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :delivered, :boolean, null: false, default: false
  end
end
