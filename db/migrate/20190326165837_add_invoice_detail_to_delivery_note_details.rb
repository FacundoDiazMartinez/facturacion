class AddInvoiceDetailToDeliveryNoteDetails < ActiveRecord::Migration[5.2]
  def change
    add_reference :delivery_note_details, :invoice_details, foreign_key: true
  end
end
