class Tribute < ApplicationRecord
  belongs_to :invoice
  after_save

  	def set_total_to_invoice
      	invoice.update_attribute(:total, invoice.sum_details + invoice.sum_tributes)
    end

    def sum_tributes
    	invoice.tributes.sum(:importe).to_f
    end
end
