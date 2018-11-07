class CreateProductPriceHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :product_price_histories do |t|
      t.references :product, foreign_key: true
      t.float :price
      t.float :percentage

      t.timestamps
    end
  end
end
