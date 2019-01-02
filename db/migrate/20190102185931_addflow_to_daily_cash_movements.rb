class AddflowToDailyCashMovements < ActiveRecord::Migration[5.2]
  def change
  	add_column :daily_cash_movements, :flow, :string, null:false, default: "income"
  	add_column :daily_cashes, :current_amount, :float, null: false
  	add_reference :daily_cash_movements, :payment, foreign_key: true
  end
end
