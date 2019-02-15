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
	#PROCESOS
end
