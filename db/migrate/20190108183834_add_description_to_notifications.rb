class AddDescriptionToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :description, :text
  end
end
