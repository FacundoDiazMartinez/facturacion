class AddServiceDateToInvoices < ActiveRecord::Migration[5.2]
  def change
  	add_column :invoices, :fch_serv_desde, :date
  	add_column :invoices, :fch_serv_hasta, :date
  end
end
