class AddPaidOutToPurchaseOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :paid_out, :boolean, default: false
  end
end
