class AddClientToPayments < ActiveRecord::Migration[5.2]
  def change
    add_reference :payments, :client, foreign_key: true
  end
end
