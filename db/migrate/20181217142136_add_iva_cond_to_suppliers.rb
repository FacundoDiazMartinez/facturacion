class AddIvaCondToSuppliers < ActiveRecord::Migration[5.2]
  def change
    add_column :suppliers, :iva_cond, :string, null: false
  end
end
