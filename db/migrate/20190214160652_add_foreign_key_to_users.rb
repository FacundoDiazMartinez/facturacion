class AddForeignKeyToUsers < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :users, :provinces
    add_foreign_key :users, :localities
  end
end
