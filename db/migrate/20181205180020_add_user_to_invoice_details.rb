class AddUserToInvoiceDetails < ActiveRecord::Migration[5.2]
  def change
    add_reference :invoice_details, :user, foreign_key: true
  end
end
