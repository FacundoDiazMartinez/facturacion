class AddObservationToBudget < ActiveRecord::Migration[5.2]
  def change
    add_column :budgets, :observation, :text
  end
end
