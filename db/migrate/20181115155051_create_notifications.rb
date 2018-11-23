class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.string :link
      t.time :read_at
      t.bigint :sender_id, null: false
      t.bigint :receiver_id

      t.timestamps
    end
  end
end
