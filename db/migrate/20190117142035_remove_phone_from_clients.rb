class RemovePhoneFromClients < ActiveRecord::Migration[5.2]
  def change
  	remove_column :clients, :phone, :string
  	remove_column :clients, :mobile_phone, :string
  	remove_column :clients, :email, :string
  	remove_column :clients, :birthday, :string
  	add_column :client_contacts, :charge, :string
  	add_column :client_contacts, :phone, :string
  end
end
