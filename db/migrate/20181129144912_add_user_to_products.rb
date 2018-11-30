class AddUserToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :created_by, :bigint
    add_column :products, :updated_by, :bigint
  end
end
