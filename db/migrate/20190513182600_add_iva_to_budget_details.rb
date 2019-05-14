class AddIvaToBudgetDetails < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_details, :iva_aliquot, :string
    add_column :budget_details, :iva_amount, :float
  end
end
