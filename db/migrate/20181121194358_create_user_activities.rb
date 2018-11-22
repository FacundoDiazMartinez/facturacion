class CreateUserActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :user_activities do |t|
      t.references :user, foreign_key: true
      t.string :photo, null: false
      t.string :title, null: false
      t.text :body, null: false
      t.string :link

      t.timestamps
    end
  end
end
