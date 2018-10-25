class CreateProductCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :product_categories do |t|
      t.string :name
      t.integer :iva_aliquot
      t.boolean :active
      t.references :company, foreign_key: true
      t.integer :products_count

      t.timestamps
    end
  end
end
