class RemoveAdminFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :admin, :boolean
    add_column :users, :admin, :boolean, null: false, default: false
  end
end