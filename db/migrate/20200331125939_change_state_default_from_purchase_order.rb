class ChangeStateDefaultFromPurchaseOrder < ActiveRecord::Migration[5.2]
  def change
    change_column :purchase_orders, :state, :string, default: "Pendiente", null: false
  end
end
