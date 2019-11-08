class CardPayment < ApplicationRecord
	include Subpayment
  	belongs_to :payment
  	belongs_to :credit_card
		belongs_to :fee, foreign_key: :installments, optional: true

		before_save :set_totals
		after_save :update_credit_card_balance

  	default_scope { where(active: true) }

		def set_totals
			self.subtotal 	= self.total
		end

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
	def intallments_by_credit_card
		if self.credit_card.blank?
			["1"]
		else
			a = [[1,0]]
			self.credit_card.fees.map{|f| a << [f.quantity, f.id]}
			return a
		end
	end
	#ATRIBUTOS

	#PROCESOS
			def update_credit_card_balance
	  		self.credit_card.update_balance_from_payment(self.payment)
	  	end

	  	def update_payment_total
	  		self.payment.update(total: self.total)
	  	end

			def destroy
	  		update_column(:active, false)
	  		run_callbacks :destroy
	  	end
	#PROCESOS
end
