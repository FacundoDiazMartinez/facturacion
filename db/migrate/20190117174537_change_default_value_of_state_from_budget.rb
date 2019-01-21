class ChangeDefaultValueOfStateFromBudget < ActiveRecord::Migration[5.2]
  def change
    change_column(:budgets, :state, :string, default: "Generado")
  end
end
