module ReceiptsHelper

	def invoices_with_link receipt
		receipt.invoices.map{|invoice| link_to "#{Afip::CBTE_TIPO[invoice.cbte_tipo]} - #{invoice.sale_point.name}-#{invoice.comp_number}", edit_invoice_path(invoice.id)}.join(", ").html_safe
	end
end
