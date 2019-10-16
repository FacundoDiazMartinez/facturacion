class AddEnabledToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :enabled, :boolean, null: false, default: true
  end
end
