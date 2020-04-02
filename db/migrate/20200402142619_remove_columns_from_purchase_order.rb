class RemoveColumnsFromPurchaseOrder < ActiveRecord::Migration[5.2]
  def change
    remove_column :purchase_orders, :paid_out, :string
    remove_column :purchase_orders, :total_pay, :string
  end
end
