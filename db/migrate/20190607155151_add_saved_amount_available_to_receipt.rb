class AddSavedAmountAvailableToReceipt < ActiveRecord::Migration[5.2]
  def change
    add_column :receipts, :saved_amount_available, :float
  end
end
