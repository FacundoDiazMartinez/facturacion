class AddDateToPurchaseOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :date, :date
  end
end
