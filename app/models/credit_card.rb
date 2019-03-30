class CreditCard < ApplicationRecord
  include Deleteable
  belongs_to :company
  has_many 	 :card_payments
  has_many   :fees

  accepts_nested_attributes_for :fees, reject_if: :all_blank, allow_destroy: true

  TYPES_OF_FEE = ["Porcentaje", "Coeficiente"]

  DEFAULT_NAMES = [["VISA", "cc-visa"],[ "American Express", "cc-amex"], ["Mastercard", "cc-mastercard"], ["PayPal", "cc-paypal"], ["Diners Club", "cc-diners-club"], ["Otra", "credit-card"]]

  def update_balance_from_payment payment
    if payment.saved_change_to_total.nil?
      new_total = [0, payment.total]
    else
      new_total =  payment.saved_change_to_total
    end
  	payment_total = new_total.last - new_total.first
    if payment.flow == "income"
      update_column(:current_amount, current_amount + payment_total)
    else
      update_column(:current_amount, current_amount - payment_total)
    end
  end

  def charge_amount(params)
    if params[:transfer_to] == "Cuenta Bancaria"
      ["income", "expense"].each do |flow|
        pay = Payment.new(
          type_of_payment: flow == "income" ? "3" : "1",
          total: params[:amount].to_f,
          payment_date: Date.today,
          flow: flow,
          company_id: self.company_id
        ).build_bank_payment(
          bank_id: flow == "income" ? params[:bank] : self.id,
          total: params[:amount].to_f
        ).save
      end
    else
      ["income", "expense"].each do |flow|
        pay = Payment.new(
          type_of_payment: flow == "income" ? "0" : "1",
          total: params[:amount].to_f,
          payment_date: Date.today,
          flow: flow,
          company_id: self.company_id
        )
        if flow == "income"
          pay.build_cash_payment(
            total: params[:amount].to_f
          )
        else
          pay.build_card_payment(
            credit_card_id: self.id,
            total: params[:amount].to_f
          )
        end
        pay.save
      end
    end
  end

end


#ENTRA DOS VECES AL METODO DE ARRIBA SOLUCIONAR ESO
