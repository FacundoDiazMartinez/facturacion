class AddStateToSalesFiles < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_files, :state, :string, null: false, default: "Abierto"
  end
end
