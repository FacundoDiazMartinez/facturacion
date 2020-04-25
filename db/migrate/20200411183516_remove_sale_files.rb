class RemoveSaleFiles < ActiveRecord::Migration[5.2]
  def change
    remove_reference :budgets, :sales_file
    remove_reference :delivery_notes, :sales_file
    drop_table :sales_files
  end
end
