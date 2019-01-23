class AddAccountMovementToPayments < ActiveRecord::Migration[5.2]
  def change
    add_reference :payments, :account_movement, foreign_key: true
  end
end
