module InvoiceManager
  class CbteTypeGetter < ApplicationService
    def initialize(invoice)
      @invoice = invoice
    end

    def call
      begin
        tipo_de_comprobante()
      rescue
        "Comprobante"
      end
    end

    private

    def tipo_de_comprobante
      Afip::CBTE_TIPO[@invoice.cbte_tipo]
    end
  end
end
