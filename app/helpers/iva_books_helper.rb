module IvaBooksHelper

	def invoice_with_link iva_book
		if iva_book.is_debit?
	        Invoice.unscoped do
	          link_to "#{IvaBook::CBTE_TIPO[iva_book.invoice.cbte_tipo]} - #{iva_book.invoice.sale_point.name}-#{iva_book.invoice.comp_number}", edit_invoice_path(iva_book.invoice_id)
	        end
	      else
	        PurchaseInvoice.unscoped do
	          link_to "#{IvaBook::CBTE_TIPO[iva_book.purchase_invoice.cbte_tipo]} - #{iva_book.purchase_invoice.number}", edit_purchase_invoice_path(iva_book.purchase_invoice_id)
	        end
	      end
	end
end
