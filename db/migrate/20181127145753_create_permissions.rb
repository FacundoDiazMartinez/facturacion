class CreatePermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :permissions do |t|
      t.string :action_name
      t.text :description
      t.references :friendly_name, foreign_key: true

      t.timestamps
    end
  end
end
