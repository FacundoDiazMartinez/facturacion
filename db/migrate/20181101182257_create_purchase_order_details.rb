class CreatePurchaseOrderDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :purchase_order_details do |t|
      t.references :purchase_order, foreign_key: true
      t.references :product, foreign_key: true
      t.float :price, null: false, default: 0.0
      t.float :quantity, null: false, default: 1
      t.float :total, null: false, default: 0.0

      t.timestamps
    end
  end
end
