class ChangeClientDefaults < ActiveRecord::Migration[5.2]
  change_column :clients, :valid_for_account, :boolean, default: false, null: false
  change_column :clients, :enabled, :boolean, default: true, null: false
end
