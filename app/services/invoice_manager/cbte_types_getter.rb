module InvoiceManager
  class CbteTypesGetter < ApplicationService
    def initialize(company, client)
      @company  = company
      @client   = client
    end

    def call
      vector_de_comprobantes()
    end

    private

    def vector_de_comprobantes
      Afip::CBTE_TIPO
        .map { |codigo, comprobante| [comprobante, codigo] if comprobantes_habilitados.include?(codigo) }
        .compact
    end

    def comprobantes_habilitados
      Afip::AVAILABLE_TYPES[condicion_iva_empresa][condicion_iva_cliente]
    end

    def condicion_iva_empresa
      @company.iva_cond_sym
    end

    def condicion_iva_cliente
      @client.iva_cond_sym
    end
  end
end
