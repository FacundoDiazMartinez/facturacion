module InvoiceManager
	class	DetailsChecker
    def initialize (invoice)
			@invoice = invoice.invoice
      @credit_note = invoice
		end

    def call
			diferencia_entre_factura_y_nc
      #return @credit_note.errors.any?
		end

		private

    def diferencia_entre_factura_y_nc
      anulada_totalmente = true
      @invoice.invoice_details.each do |invoice_detail|
        invoice_product     = invoice_detail.product
        invoice_quantity    = invoice_detail.quantity
        cn_detail_quantity  = 0

        @invoice.credit_notes.each do |credit_note|
          credit_note.invoice_details.where(product_id: invoice_product.id).each do |cn_detail|
            cn_detail_quantity += cn_detail.quantity
          end
        end

        @credit_note.invoice_details.where(product_id: invoice_product.id).each do |actual_cn|
          cn_detail_quantity += actual_cn.quantity
        end
        cn_detail_quantity

        if cn_detail_quantity > invoice_quantity
          @credit_note.errors.add(:quantity, "La cantidad ingresada de uno o más de los productos supera a la cantidad de la factura inicial asociada.")
        end
      end
    end
	end
end
