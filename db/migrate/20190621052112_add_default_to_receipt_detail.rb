class AddDefaultToReceiptDetail < ActiveRecord::Migration[5.2]
  def change
    change_column :receipt_details, :total, :float, default: 0.0
  end
end
