class AddObservationToDailyCashMovement < ActiveRecord::Migration[5.2]
  def change
    add_column :daily_cash_movements, :observation, :string
  end
end
