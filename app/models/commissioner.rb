class Commissioner < ApplicationRecord
  	belongs_to :user
  	belongs_to :invoice_detail, optional: true

  	after_save :set_total

  	def set_total
  		pp invoice
  		if invoice.is_credit_note? 
  		 	update_column(:total_commission, -(invoice.total.to_f * percentage.to_f / 100))
  		else
  			update_column(:total_commission, invoice.total.to_f * percentage.to_f / 100)
  		end
  	end

  	def invoice
  		invoice_detail.invoice
  	end

  	def full_number
  		invoice.editable? ? "Sin confirmar" : invoice.full_number
  	end

  	def cbte_fch
  		invoice.editable? ? "Sin confirmar" : invoice.cbte_fch
  	end

  	def total
		invoice.total
  	end

  	def tipo
  		invoice.tipo
  	end

  	def self.search_by_date from, to
	  	if !from.blank? && !to.blank?
	  		if from.respond_to?(:to_time) && to.respond_to?(:to_time)
	  			where(created_at: from.to_time.beginning_of_day..to.to_time.end_of_day)
	  		else
	  			all
	  		end
		else
			all
		end
	end
end
