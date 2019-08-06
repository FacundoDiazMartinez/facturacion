module InvoiceManager
	class	StateChecker
    def initialize (invoice)
			@associated_invoice = invoice.invoice
      @invoice = invoice
		end

    def call
			#check_state
		end

    def check_state
      anulada_totalmente = true
      pp invoice_quantity = 0
      pp cn_detail_quantity  = 0
      @associated_invoice.invoice_details.each do |invoice_detail|
        invoice_quantity += invoice_detail.quantity
        @associated_invoice.credit_notes.each do |credit_note|
          credit_note.invoice_details.each do |cn_detail|
            cn_detail_quantity += cn_detail.quantity
          end
        end
      end
    end
    if invoice_quantity == cn_detail_quantity
      @associated_invoice.update_columns(state: "Anulado")
    else
      @associated_invoice.update_columns(state: "Anulado parcialmente")
    end
	end
end
