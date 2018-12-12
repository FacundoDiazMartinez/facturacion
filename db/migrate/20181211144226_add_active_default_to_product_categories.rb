class AddActiveDefaultToProductCategories < ActiveRecord::Migration[5.2]
  def change
    remove_column :product_categories, :active, :boolean
  	add_column :product_categories, :active, :boolean, default: true, null: false
  end
end
