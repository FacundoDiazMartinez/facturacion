class ChangeClientDefaults < ActiveRecord::Migration[5.2]
  def up
    change_column :clients, :valid_for_account, :boolean, default: false, null: false
    remove_column :clients, :enabled, :boolean
    add_column :clients, :enabled, :boolean, null: false, default: true
  end
  def down
  end
end
