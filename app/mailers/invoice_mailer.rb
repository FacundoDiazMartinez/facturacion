class InvoiceMailer < ApplicationMailer

	def send_to_client invoice, email, barcode_path
		@invoice = invoice
		Product.unscoped do
	      	@group_details = @invoice.invoice_details.includes(:product).in_groups_of(20, fill_with= nil)
	    end
	    @barcode_path = barcode_path
		attachments['factura.pdf'] = render_to_string(pdf: "factura.pdf", template: 'invoices/show.pdf.erb', layout: 'pdf.html')
		mail to: email, subject: "Factura Nº #{invoice.full_number} - #{invoice.company.name}"
	end

end
