class ChangeNumberToPurchaseOrders < ActiveRecord::Migration[5.2]
  def change
  	change_column :purchase_orders, :number, :string, null: false
  end
end
