class AddTipoToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :tipo, :string, null: false, default: "Producto"
  end
end
