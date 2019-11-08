class AddFeeReferenceToCardPayment < ActiveRecord::Migration[5.2]
  def change
    add_reference :card_payments, :fee, foreign_key: true
    add_column :card_payments, :fee_subtotal, :decimal, precision: 8, scale: 2
  end
end
