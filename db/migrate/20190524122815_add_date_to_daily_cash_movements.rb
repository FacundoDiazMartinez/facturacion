class AddDateToDailyCashMovements < ActiveRecord::Migration[5.2]
  def change
    add_column :daily_cash_movements, :date, :date
    change_column :daily_cash_movements, :movement_type, :string, default: 'Ajuste'
  end
end
