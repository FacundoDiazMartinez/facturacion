class AddInternalObservationToBudget < ActiveRecord::Migration[5.2]
  def change
    add_column :budgets, :internal_observation, :text
  end
end
