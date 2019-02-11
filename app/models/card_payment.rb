class CardPayment < ApplicationRecord
	include Subpayment
  	belongs_to :payment
  	belongs_to :credit_card

  	after_save :update_credit_card_balance

  	default_scope { where(active: true) }

  	#FILTROS DE BUSQEUDA
	  	def self.search_by_card card
	  		if !card.blank?
	  			where("credit_cards.name = ?", card)
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
