class ChangeNotNullToPuchaseInvoiceImpOpEx < ActiveRecord::Migration[5.2]
  def change
    change_column :purchase_invoices, :imp_op_ex, :float, :null => true
  end
end
