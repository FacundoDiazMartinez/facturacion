class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.string :code
      t.string :name
      t.boolean :active
      t.references :product_category, foreign_key: true
      t.references :company, foreign_key: true
      t.float :cost_price
      t.float :gain_margin
      t.float :net_price
      t.float :price
      t.string :iva_aliquot
      t.string :photo
      t.string :measurement_unit

      t.timestamps
    end
  end
end
