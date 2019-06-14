class ReceiptDetail < ApplicationRecord
  belongs_to :receipt
  belongs_to :invoice
  validate   :invoices_clients_validation
  has_one    :invoice_payment, ->(rd){joins(:invoice).where(generated_by_system: true, account_movement_id: rd.receipt.account_movement.id, invoices: {cbte_tipo: Invoice::COD_INVOICE})}, through: :invoice, class_name: "IncomePayment", source: :income_payments
  scope      :only_invoices, -> {joins(:invoice).where(invoices: {cbte_tipo: Invoice::COD_INVOICE})}

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

  def save_amount_available
    saved_total = self.invoice.total
    self.invoice.update_column(:saved_total_for_receipt_pdf, saved_total)
  end

  def associated_invoices_total
    if invoice.nil?
      return "$ 0"
    else
      return "$ #{invoice.confirmed_notes.sum(:total)}"
    end
  end
end
