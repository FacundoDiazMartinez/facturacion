class AddNumberToReceipt < ActiveRecord::Migration[5.2]
  def change
    add_column :receipts, :number, :string
  end
end
