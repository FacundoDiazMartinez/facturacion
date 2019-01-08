class AddAvailableStockToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :available_stock, :float, null: false, default: 0.0
  end
end
