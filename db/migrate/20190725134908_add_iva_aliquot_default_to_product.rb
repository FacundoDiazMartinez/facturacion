class AddIvaAliquotDefaultToProduct < ActiveRecord::Migration[5.2]
  def change
    change_column :products, :iva_aliquot, :string, default: "05", null: false
  end
end
