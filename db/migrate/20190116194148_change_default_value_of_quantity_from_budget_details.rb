class ChangeDefaultValueOfQuantityFromBudgetDetails < ActiveRecord::Migration[5.2]
  def change
    change_column(:budget_details, :quantity, :float, default: 1)
  end
end
