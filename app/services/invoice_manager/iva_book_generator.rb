module InvoiceManager
  class IvaBookGenerator < ApplicationService
    def initialize(invoice)
      @invoice = invoice
    end

    def call
      genera_nuevo_registro_de_libro_iva!
    end

    private

    def genera_nuevo_registro_de_libro_iva!
      if @invoice.confirmado?
        ib = prepara_libro_iva

        ib.save unless !ib.changed?
      end
    end

    def prepara_libro_iva
      ib            = IvaBook.where(
        invoice_id: @invoice.id,
        company_id: @invoice.company_id,
        date:       @invoice.cbte_fch
      ).first_or_initialize
      ib.tipo       = ib.clase
      if @invoice.is_credit_note?
        ib.net_amount = - @invoice.imp_neto
        ib.iva_amount = - @invoice.imp_iva
      else
        ib.net_amount = @invoice.imp_neto
        ib.iva_amount = @invoice.imp_iva
      end
      ib.total      = ib.net_amount + ib.iva_amount

      return ib
    end
  end
end
