class AddIssuanceDateToChequePayment < ActiveRecord::Migration[5.2]
  def change
    add_column :cheque_payments, :issuance_date, :date, null: false, default: -> { "CURRENT_DATE" }
  end
end
