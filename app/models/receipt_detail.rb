class ReceiptDetail < ApplicationRecord
  belongs_to :receipt
  belongs_to :invoice
  validate :invoices_clients_validation

	def self.save_from_invoice receipt, invoice
  	rd = ReceiptDetail.where(invoice_id: invoice.id, receipt_id: receipt.id).first_or_initialize
  	rd.total = receipt.total
  	rd.save
 	end

 	def invoice_comp_number
 		invoice.nil? ? "" : invoice.full_number
 	end

  def invoices_clients_validation
    if self.receipt.client_id != self.invoice.client_id
      self.receipt.errors.add(:client_id, "El cliente del recibo debe coincidir con el cliente de cada factura.")
    end
  end

end
