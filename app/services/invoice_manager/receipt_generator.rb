module InvoiceManager
  class ReceiptGenerator < ApplicationService
    ##genera un recibo nuevo asociado a la factura (a traves de receipt_details)
    def initialize(invoice)
      @invoice = invoice
    end

    def call
      recibo = genera_recibo()
      recibo.save!
      detalle = genera_detalle_del_recibo(recibo, @invoice)
      detalle.save!
      genera_movimiento_de_cuenta(recibo, @invoice)

      if @invoice.on_account?
        ReceiptManager::Confirmator.call(recibo)
      else
        ReceiptManager::OutboundAccountConfirmator.call(recibo)
      end
    end

    private

    def genera_recibo
      recibo = Receipt.new.tap do |r|
        r.cbte_tipo     = @invoice.is_credit_note? ? "99" : "00"
        r.total         = @invoice.total_pay
        r.date          = @invoice.created_at
        r.company_id    = @invoice.company_id
        r.client_id     = @invoice.client_id
        r.sale_point_id = @invoice.sale_point_id
        r.user_id       = @invoice.user_id
      end
      return recibo
    end

    def genera_detalle_del_recibo(recibo, invoice)
      rd             = ReceiptDetail.where(invoice_id: invoice.id, receipt_id: recibo.id).first_or_initialize
      rd.total       = recibo.total
      return rd
    end

    def genera_movimiento_de_cuenta(recibo, invoice)
      am             = AccountMovement.unscoped.where(receipt_id: recibo.id).first_or_initialize
      am.client_id   = recibo.client_id
      am.receipt_id  = recibo.id
      am.cbte_tipo   = Receipt::CBTE_TIPO[recibo.cbte_tipo]
      am.debe        = recibo.cbte_tipo == "99"
      am.haber       = recibo.cbte_tipo != "99"
      am.total       = recibo.total
      am.saldo       = 0
      am.active      = false
      am.save!

      if invoice.on_account?
        invoice.income_payments.where(generated_by_system: false, account_movement_id: nil).each do |income_payment|
          income_payment.account_movement_id = am.id
          income_payment.invoice_id          = nil
          income_payment.save!
        end
      end
    end
  end
end
