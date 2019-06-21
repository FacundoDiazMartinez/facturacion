class AddRealTotalLeftToReceiptDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :receipt_details, :rtl_invoice, :float
  end
end
