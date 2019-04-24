class AddContactToClient < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :contact_1, :string
    add_column :clients, :contact_2, :string
  end
end
