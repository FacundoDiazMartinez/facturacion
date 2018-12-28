class AddObservationToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :observation, :text
  end
end
