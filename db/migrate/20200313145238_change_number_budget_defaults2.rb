class ChangeNumberBudgetDefaults2 < ActiveRecord::Migration[5.2]
  def change
    change_column :budgets, :number, :string, null: true
  end
end
