class CreateClientContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :client_contacts do |t|
      t.references :client, foreign_key: true
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
