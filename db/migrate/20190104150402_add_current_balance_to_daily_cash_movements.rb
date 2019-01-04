class AddCurrentBalanceToDailyCashMovements < ActiveRecord::Migration[5.2]
  def change
    add_column :daily_cash_movements, :current_balance, :float, null: false, default: 0.0
  end
end
