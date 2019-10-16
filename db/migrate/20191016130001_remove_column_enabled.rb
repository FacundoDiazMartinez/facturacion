class RemoveColumnEnabled < ActiveRecord::Migration[5.2]
  def change
    remove_column  :clients, :enabled, :boolean
    add_column     :clients, :enabled, :boolean, default: true, null: false
  end
end
