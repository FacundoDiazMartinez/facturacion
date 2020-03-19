class AddDefaultsToStocks < ActiveRecord::Migration[5.2]
  def change
    change_column :stocks, :state, :string, null: false
    change_column :stocks, :quantity, :float, default: 0, null: false
  end
end
