class RemoveSalesFileFromInvoice < ActiveRecord::Migration[5.2]
  def change
    remove_column :invoices, :sales_file_id, :string
  end
end
