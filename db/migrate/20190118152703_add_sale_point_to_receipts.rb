class AddSalePointToReceipts < ActiveRecord::Migration[5.2]
  def change
    add_reference :receipts, :sale_point, foreign_key: true
  end
end
