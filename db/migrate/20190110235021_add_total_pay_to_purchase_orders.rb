class AddTotalPayToPurchaseOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :total_pay, :float, null: false, default: 0.0
  end
end
