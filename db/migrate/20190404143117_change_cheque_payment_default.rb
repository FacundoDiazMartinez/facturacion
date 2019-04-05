class ChangeChequePaymentDefault < ActiveRecord::Migration[5.2]
  def change
  	change_column_default(:cheque_payments, :origin, 'De tercero')
  end
end
