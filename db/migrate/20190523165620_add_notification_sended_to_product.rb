class AddNotificationSendedToProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :notification_sended, :boolean, default: false, null: false
  end
end
