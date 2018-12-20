class AddFchaVtoPagoToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :fch_vto_pago, :date
  end
end
