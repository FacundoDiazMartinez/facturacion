module InvoiceManager
  class ReceiptGenerator < ApplicationService
    def initialize(invoice)
      @invoice = invoice
    end

    def call
      ActiveRecord::Transaction do

      rescue ActiveRecord
      end
    end

    private

    def method
      if invoice.receipts.empty?
        ##genera un recibo nuevo asociado a la factura (a traves de receipt_details)
        r               = Receipt.new
        r.cbte_tipo     = invoice.is_credit_note? ? "99" : "00"
        r.total         = invoice.total_pay
        r.date          = invoice.created_at
        r.company_id    = invoice.company_id
        r.client_id     = invoice.client_id
        r.sale_point_id = invoice.sale_point_id
        r.user_id       = invoice.user_id
        if r.save
          ReceiptDetail.save_from_invoice(r, invoice) ##genera un detalle para el recibo con vinculación a la factura
          AccountMovement.generate_from_receipt_from_invoice(r, invoice) ##genera un movimiento de cuenta con todos los pagos de la factura
          r.reload ##IMPORTANTE recarga asociaciones
          r.confirmar!
          r.reload
        else
          pp r.errors
        end
      end
    end
  end
end


## genera un recibo de pago cuando una factura confirmada tiene pagos
## ejecutado en after_save de invoice
def self.create_from_invoice invoice

  if invoice.confirmado? && invoice.total_pay > 0

  end
end
