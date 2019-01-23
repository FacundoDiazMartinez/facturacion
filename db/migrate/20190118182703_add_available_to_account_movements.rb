class AddAvailableToAccountMovements < ActiveRecord::Migration[5.2]
  def change
    add_column :account_movements, :amount_available, :float, null: false, default: 0.0
  end
end
