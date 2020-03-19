class ChangeStateBudgetDefaults < ActiveRecord::Migration[5.2]
  def change
    change_column :budgets, :state, :string, default: nil, null: false
  end
end
