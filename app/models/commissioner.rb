class Commissioner < ApplicationRecord
  	belongs_to :user
  	belongs_to :invoice_detail

  	before_validation :set_total

  	def set_total
  		self.total_commission = invoice.total.to_f * percentage.to_f / 100
  	end

  	def invoice
  		invoice_detail.invoice
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
