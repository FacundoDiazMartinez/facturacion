class AddStockRecomendationsToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :minimum_stock, :float
    add_column :products, :recommended_stock, :float
  end
end
