class AddActiveToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :active, :boolean, null: false, default: true
    add_column :payments, :payment_date, :date
  end
end
