class AddEnabledToClient < ActiveRecord::Migration[5.2]
  def change
		add_column	:clients, :enabled, :boolean, default: true
		add_column	:clients, :enabled_observation, :string
  end
end
