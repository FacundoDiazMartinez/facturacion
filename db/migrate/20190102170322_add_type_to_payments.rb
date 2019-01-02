class AddTypeToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :flow, :string, null: false, default: "income"
    add_reference :payments, :purchase_order, foreign_key: true
  end
end
