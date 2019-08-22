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

    def diferencia_entre_factura_y_nc
      anulada_totalmente = true
      pp @invoice
      pp @invoice.invoice_details
      @invoice.invoice_details.each do |invoice_detail|
        invoice_product     = invoice_detail.product
        pp invoice_quantity    = invoice_detail.quantity
        cn_detail_quantity  = 0

        @invoice.credit_notes.each do |credit_note|
          credit_note.invoice_details.where(product_id: invoice_product.id).each do |cn_detail|
            cn_detail_quantity += cn_detail.quantity
          end
        end

        @credit_note.invoice_details.where(product_id: invoice_product.id).each do |actual_cn|
          cn_detail_quantity += actual_cn.quantity
        end
        pp cn_detail_quantity

        if cn_detail_quantity > invoice_quantity
          @credit_note.errors.add(:quantity, "La cantidad ingresada de uno o más de los productos supera a la cantidad de la factura inicial asociada.")
        end
      end
    end
	end
end

# anulada_totalmente = true
# invoice = self.invoice
# invoice.invoice_details.each do |invoice_detail|
#   invoice_product     = invoice_detail.product
#   invoice_quantity    = invoice_detail.quantity
#   cn_detail_quantity  = 0
#
#   invoice.credit_notes.each do |credit_note|
#     credit_note.invoice_details.where(product_id: invoice_product.id).each do |cn_detail|
#       cn_detail_quantity += cn_detail.quantity
#     end
#   end
#
#   self.invoice_details.each do |cn_detail|
#     if cn_detail.product_id == invoice_product.id
#       cn_detail_quantity += cn_detail.quantity
#     end
#   end
#   if cn_detail_quantity > invoice_quantity
#     errors.add(:quantity, "La cantidad ingresada de uno o más de los productos supera a la cantidad de la factura inicial asociada.")
#   elsif cn_detail_quantity < invoice_quantity
#     #ACTUALIZA LA FACTURA A ANULADA parcialmente
#     anulada_totalmente = false
#   end
# end
# unless self.errors.any?
#   if anulada_totalmente
#     invoice.update_columns(state: "Anulado")
#   else
#     invoice.update_columns(state: "Anulado parcialmente")
#   end
# end
