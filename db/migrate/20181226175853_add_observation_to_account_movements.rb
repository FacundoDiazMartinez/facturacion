class AddObservationToAccountMovements < ActiveRecord::Migration[5.2]
  def change
    add_column :account_movements, :observation, :text
  end
end
