class CreditCard < ApplicationRecord
  belongs_to :company
  has_many 	 :card_payments
  has_many   :fees

  accepts_nested_attributes_for :fees, reject_if: :all_blank, allow_destroy: true

  TYPES_OF_FEE = ["Porcentaje", "Coeficiente"]

  DEFAULT_NAMES = [["VISA", "cc-visa"],[ "American Express", "cc-amex"], ["Mastercard", "cc-mastercard"], ["PayPal", "cc-paypal"], ["Diners Club", "cc-diners-club"], ["Otra", "credit-card"]]

  def update_balance_from_payment payment
    if payment.flow == "income"
      if payment.saved_change_to_total.nil?
        new_total = [0, payment.total]
      else
        new_total =  payment.saved_change_to_total
      end
    	payment_total = new_total.last - new_total.first
    	update_column(:current_amount, current_amount + payment_total)
    end
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

  def charge_amount(params)
    update_column(:current_amount, current_amount - params[:amount].to_f)
    if params[:transfer_to] == "Cuenta Bancaria"
      pay = Payment.new(
        type_of_payment: "3",
        total: params[:amount].to_f,
        payment_date: Date.today,
        flow: "income",
        company_id: self.company_id
      )
      pay.build_bank_payment(
        bank_id: params[:bank],
        total: params[:amount].to_f
      )
    else
      pay = Payment.new(
        type_of_payment: "0",
        total: params[:amount].to_f,
        payment_date: Date.today,
        flow: "income",
        company_id: self.company_id
      )
      pay.build_cash_payment(
        total: params[:amount].to_f
      )
    end
    pay.save
  end

end


#ENTRA DOS VECES AL METODO DE ARRIBA SOLUCIONAR ESO
