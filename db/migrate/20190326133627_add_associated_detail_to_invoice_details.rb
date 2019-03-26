class AddAssociatedDetailToInvoiceDetails < ActiveRecord::Migration[5.2]
  def change
    add_column :invoice_details, :associated_detail, :bigint
  end
end
