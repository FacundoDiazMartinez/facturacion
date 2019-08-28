module InvoiceManager
	class	Canceller
		def initialize (invoice)
			@associated_invoice = invoice
		end

		def call
			invoice = copiar_datos_de_la_factura_asociada
			asignar_detalles_de_la_factura(invoice)
			asignar_tributos_de_la_factura(invoice)
			return invoice
		end

		private

		def copiar_datos_de_la_factura_asociada
			atributos = @associated_invoice.attributes
			invoice = @associated_invoice.user.company.invoices.build(associated_invoice: @associated_invoice.id)
    	invoice.attributes = atributos.except!(*["id", "state", "cbte_tipo", "header_result", "authorized_on", "cae_due_date", "cae", "cbte_fch", "comp_number", "associated_invoice", "total_pay"])
			invoice.cbte_tipo = (@associated_invoice.cbte_tipo.to_i + 2).to_s.rjust(2,padstr= '0').to_s
    	invoice.cbte_fch = Date.today
    	return invoice
		end

		def asignar_detalles_de_la_factura (invoice)
			@associated_invoice.invoice_details.each do |detail|
				invoice_detail = invoice.invoice_details.build(detail.attributes.except!(*["id", "invoice_id"]))
        @associated_invoice.credit_notes.each do |cn|
          cn.invoice_details.where(product_id: detail.product_id).each do |cn_detail|
            invoice_detail.quantity -= cn_detail.quantity
          end
        end
      end
		end

		def asignar_tributos_de_la_factura(invoice)
			if invoice.tributes.size > 0
        invoice.tributes.each do |tribute|
          invoice.tributes.build(tribute.attributes.except!(*["id", "invoice_id"]))
        end
      end
		end
	end
end
