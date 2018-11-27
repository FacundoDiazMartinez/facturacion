class CreateFriendlyNames < ActiveRecord::Migration[5.2]
  def change
    create_table :friendly_names do |t|
      t.string :name
      t.string :subject_class

      t.timestamps
    end
  end
end
