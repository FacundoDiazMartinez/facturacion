class AddNullsAndDefaultsToCompensationPayments < ActiveRecord::Migration[5.2]
  def change
    change_column :compensation_payments, :total, :float, null: false
    change_column :compensation_payments, :active, :boolean, null: false, default: true
    change_column :compensation_payments, :total, :float, null: false
  end
end
