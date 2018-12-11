class AddActiveDefaultToProductCategories < ActiveRecord::Migration[5.2]
  def change
  	change_column :product_categories, :active, :boolean, default: true, null: false
  end
end
