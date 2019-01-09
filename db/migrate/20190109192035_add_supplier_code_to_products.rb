class AddSupplierCodeToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :supplier_code, :string
  end
end
