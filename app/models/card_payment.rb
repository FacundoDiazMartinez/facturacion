class CardPayment < ApplicationRecord
	include Subpayment
  	belongs_to :payment
  	belongs_to :credit_card
		belongs_to :fee, foreign_key: :installments, optional: true

		before_save :set_totals
		after_save :update_credit_card_balance

		validates_presence_of :fee_id, message: 'Seleccione la cantidad de cuotas.'

  	default_scope { where(active: true) }

		def set_totals
		  fee = Fee.find(self.fee_id)
			self.installments = fee.quantity
			self.interest_rate_percentage = fee.percentage

			aux_total 	= self.subtotal * (self.interest_rate_percentage / 100.to_f + 1)
			valor_cuota = aux_total.to_f / self.installments
			aux_total = valor_cuota.round(2).to_f * self.installments.to_f

			self.fee_subtotal = valor_cuota
			self.total 	= aux_total.round(2)
			pp fee_subtotal
			pp total
		end

		# :interest_rate_amount, :total

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
