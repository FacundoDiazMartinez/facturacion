class Bank < ApplicationRecord
  belongs_to :company
  has_many :bank_payments

  validates_presence_of :name,           message: "El nombre no puede estar en blanco."
  validates_presence_of :account_number, message: "El número de cuenta no puede estar en blanco."
  validates :cbu,
    presence: { message: "El CBU no puede estar en blanco." },
    length: { minimum: 22, maximum: 22, message: "C.B.U. inválido. Verifique por favor. Cantidad necesaria de caracteres = 22."}

  validates :current_amount,
    presence: { message: "Ingrese el monto inicial que quiere asignar al nuevo banco."},
    numericality: { greater_than_or_equal_to: 0, message: "El monto inicial debe ser mayor o igual a 0." }


  def update_balance_from_payment payment
    if payment.saved_change_to_total.nil?
      payment_total = payment.total
    else
      new_total =  payment.saved_change_to_total
    	payment_total = new_total.last - new_total.first
    end
    if payment.flow == "income"
  	   update_column(:current_amount, current_amount + payment_total)
     else
       update_column(:current_amount, current_amount - payment_total)
     end
  end

  def extract_amount(params)
    if params[:transfer_to] == "Cuenta Bancaria"
      ["income", "expense"].each do |flow|
        pay = Payment.new(
          type_of_payment: "3",
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
          type_of_payment: flow == "income" ? "0" : "3",
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
          pay.build_bank_payment(
            bank_id: self.id,
            total: params[:amount].to_f
          )
        end
        pay.save
      end
    end
  end

end
