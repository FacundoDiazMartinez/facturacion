class AddCreatedByToProductPriceHistories < ActiveRecord::Migration[5.2]
  def change
    add_column :product_price_histories, :created_by, :bigint
  end
end
