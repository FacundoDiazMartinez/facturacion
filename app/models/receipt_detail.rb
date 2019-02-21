class ReceiptDetail < ApplicationRecord
  belongs_to :receipt
  belongs_to :invoice

  	def self.save_from_invoice receipt, invoice
	  	rd = ReceiptDetail.where(invoice_id: invoice.id, receipt_id: receipt.id).first_or_initialize
		rd.total = receipt.total
		rd.save
 	end

 	def invoice_comp_number
 		invoice.nil? ? "" : invoice.full_number
 	end
end
