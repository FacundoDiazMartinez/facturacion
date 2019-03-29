class ChequePayment < ApplicationRecord
	include Subpayment
  	belongs_to :payment

  	STATES = ["Cobrado", "No cobrado"]

  	ORIGINS =["Propio", "De tercero"]

  	#FILTROS DE BUSQEUDA
	  	def self.search_by_number number
	  		if !number.blank?
	  			where("number ILIKE ?", "%#{number}%")
	  		else
	  			all
	  		end
	  	end
	#FILTROS DE BUSQUEDA

	#ATRIBUTOS
		def generator_name
			payment.user_id.blank? ? "Sistema" : payment.user.name
		end
	#ATRIBUTOS

	#PROCESOS
		def update_credit_card_balance
	  		self.credit_card.update_balance_from_payment(self.payment)
	  	end

	  	def update_payment_total
	  		self.payment.update(total: self.total)
	  	end

			def charge_amount(params, company_id)
		    update_column(:state, "Cobrado")
		    if params[:transfer_to] == "Cuenta Bancaria"
		      pay = Payment.new(
		        type_of_payment: "3",
		        total: params[:amount].to_f,
		        payment_date: Date.today,
		        flow: "income",
		        company_id: company_id
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
		        company_id: company_id
		      )
		      pay.build_cash_payment(
		        total: params[:amount].to_f
		      )
		    end
		    pay.save
		  end
	#PROCESOS
end
