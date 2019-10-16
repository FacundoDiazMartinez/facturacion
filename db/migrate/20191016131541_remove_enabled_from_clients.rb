class RemoveEnabledFromClients < ActiveRecord::Migration[5.2]
  def change
    remove_column :clients, :enabled, :boolean
  end
end
