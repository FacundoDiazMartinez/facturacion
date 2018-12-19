class RemoveIvaAliquotFromProductCategories < ActiveRecord::Migration[5.2]
  def change
    remove_column :product_categories, :iva_aliquot, :integer
    add_column :product_categories, :iva_aliquot, :string, null: false, default: "05"
  end
end
