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
      ib = prepara_libro_iva()

      ib.save unless !ib.changed?
    end

    def prepara_libro_iva
      libro_iva  = IvaBook.where(
        invoice_id: @invoice.id,
        company_id: @invoice.company_id,
        date:       @invoice.cbte_fch
      ).first_or_initialize
      libro_iva.tipo       = libro_iva.clase

      if @invoice.is_credit_note?
        libro_iva.net_amount = - @invoice.imp_neto
        libro_iva.iva_amount = - @invoice.imp_iva
      else
        libro_iva.net_amount = @invoice.imp_neto
        libro_iva.iva_amount = @invoice.imp_iva
      end
      libro_iva.total      = libro_iva.net_amount + libro_iva.iva_amount

      return libro_iva
    end
  end
end
