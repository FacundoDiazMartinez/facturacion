class AddAttributesToSuppliers < ActiveRecord::Migration[5.2]
  def change
    add_column :suppliers, :titular, :string
    add_column :suppliers, :account_number, :string
    add_column :suppliers, :bank_name, :string
  end
end
