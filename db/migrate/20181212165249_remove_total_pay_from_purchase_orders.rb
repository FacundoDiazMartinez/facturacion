class RemoveTotalPayFromPurchaseOrders < ActiveRecord::Migration[5.2]
  def change
    remove_column :purchase_orders, :total_pay
  end
end
