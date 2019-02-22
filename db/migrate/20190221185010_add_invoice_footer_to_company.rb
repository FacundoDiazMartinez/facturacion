class AddInvoiceFooterToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :invoice_footer, :string
  end
end
