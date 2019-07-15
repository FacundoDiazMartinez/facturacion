class InvoiceMailer < ApplicationMailer

	def send_to_client invoice, email, barcode_path
		@invoice = invoice
		@email = email
		Product.unscoped do
	      	@group_details = @invoice.invoice_details.includes(:product).in_groups_of(20, fill_with= nil)
	    end
	    @barcode_path = barcode_path
		unless @invoice.nil?
	      	attachments["#{invoice.account_movement.comprobante}.pdf"] = WickedPdf.new.pdf_from_string(
	      		render_to_string(pdf: 'Factura', template: 'invoices/show.pdf.erb', layout: 'pdf.html')
	     	)
	     	@invoice.receipts.each do |receipt|
	     		@receipt = receipt
	     		@parent_receipt_details = @receipt.receipt_details.joins(:invoice).where(invoices: {associated_invoice: nil})
		     	attachments["#{receipt.full_name}.pdf"] = WickedPdf.new.pdf_from_string(
		      		render_to_string(pdf: 'Recibo', template: 'receipts/show.pdf.erb', layout: 'pdf.html')
		     	)
		    end
	      	mail to: email, subject: "Factura Nº #{invoice.full_number} - #{invoice.company.name}"
	    end
	end

end
