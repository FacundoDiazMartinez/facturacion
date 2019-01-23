class AddClientToReceipts < ActiveRecord::Migration[5.2]
  def change
    add_reference :receipts, :client, foreign_key: true
  end
end
