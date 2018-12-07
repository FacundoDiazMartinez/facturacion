class AddSupplierToProductCategories < ActiveRecord::Migration[5.2]
  def change
    add_reference :product_categories, :supplier, foreign_key: true
  end
end
