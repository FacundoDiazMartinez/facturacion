class ChangeNumberBudgetDefaults < ActiveRecord::Migration[5.2]
  def change
    change_column :budgets, :number, :string
  end
end
