class CreditCard < ApplicationRecord
  belongs_to :company
  has_many 	 :card_payments
  has_many   :fees

  accepts_nested_attributes_for :fees, reject_if: :all_blank, allow_destroy: true

  TYPES_OF_FEE = ["Porcentaje", "Coeficiente"]

  DEFAULT_NAMES = [["VISA", "cc-visa"],[ "American Express", "cc-amex"], ["Mastercard", "cc-mastercard"], ["PayPal", "cc-paypal"], ["Diners Club", "cc-diners-club"], ["Otra", "credit-card"]]

  def update_balance_from_payment payment
  	payment_total = payment.total - payment.total_was
  	update_column(:current_amount, current_amount + payment_total)
  end

  def destroy (hard = nil)
    if hard
      super
    else
      update_column(:active, false)
      run_callbacks :destroy
      freeze
    end
  end

end


#ENTRA DOS VECES AL METODO DE ARRIBA SOLUCIONAR ESO
