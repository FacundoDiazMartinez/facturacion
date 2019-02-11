class CreditCard < ApplicationRecord
  belongs_to :company
  has_many 	 :card_payments

  def update_balance_from_payment payment
  	payment_total = payment.total - payment.total_was
  	update_column(:current_amount, current_amount + payment_total)
  end

end


#ENTRA DOS VECES AL METODO DE ARRIBA SOLUCIONAR ESO