module InvoiceManager
  class AccountMovementGenerator < ApplicationService
    ##genera movimiento de cuenta corriente ROJO desde una factura (o nota) o VERDE desde una nota

    def initialize(invoice)
      @invoice = invoice
    end

    def call
      monto_faltante_comprobante_asociado = calcula_saldo_disponible()
      movimiento_de_cuenta                = genera_movimiento_de_cuenta(monto_faltante_comprobante_asociado)

      movimiento_de_cuenta.save!
      movimiento_de_cuenta.confirmar!
    end

    private

    def calcula_saldo_disponible
      return @invoice.invoice.real_total_left if @invoice.is_credit_note? && @invoice.invoice
      return 0
    end

    def genera_movimiento_de_cuenta(saldo_disponible = 0)
      am              = AccountMovement.where(invoice_id: @invoice.id).first_or_initialize
      am.client_id    = @invoice.client_id
      am.invoice_id   = @invoice.id
      am.cbte_tipo    = @invoice.tipo
      am.observation  = @invoice.observation
      am.total        = @invoice.total.to_f
      am.debe         = true
      am.haber        = false
      if @invoice.is_credit_note?
        am.amount_available = (@invoice.total - saldo_disponible) < 0 ? 0 : @invoice.total - saldo_disponible
        am.debe             = false
        am.haber            = true
      end

      return am
    end

  end
end
