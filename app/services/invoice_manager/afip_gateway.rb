module InvoiceManager
  class AfipGateway < ApplicationService

    def initialize(comprobante)
      @bill = comprobante
    end

    def call
      establece_constantes
      comprobante = Afip::Bill.new(
        net:            @bill.net_amount_sum,
        doc_num:        @bill.client.document_number,
        sale_point:     @bill.sale_point.name,
        documento:      Afip::DOCUMENTOS.key(@bill.client.document_type),
        moneda:         @bill.company.moneda.parameterize.underscore.gsub(" ", "_").to_sym,
        iva_cond:       @bill.client.iva_cond.parameterize.underscore.gsub(" ", "_").to_sym,
        concepto:       @bill.concepto,
        ivas:           @bill.iva_array,
        cbte_type:      @bill.cbte_tipo,
        fch_serv_desde: @bill.fch_serv_desde,
        fch_serv_hasta: @bill.fch_serv_hasta,
        due_date:       @bill.fch_vto_pago,
        tributos:       @bill.tributes.map{|t| [t.afip_id, t.desc, t.base_imp, t.alic, t.importe]},
        cant_reg:       1,
        no_gravado:     @bill.no_gravado,
        exento:         @bill.exento,
        otros_imp:      @bill.otros_imp
      )
      comprobante.doc_num = @bill.client.document_number
      return comprobante
    end

    private
    
    def establece_constantes
      if @bill.company.environment == "production"
        #PRODUCCION
        Afip.pkey               = "#{Rails.root}/app/afip/facturacion.key"
        Afip.cert               = "#{Rails.root}/app/afip/produccion.crt"
        Afip.auth_url           = "https://wsaa.afip.gov.ar/ws/services/LoginCms"
        Afip.service_url        = "https://servicios1.afip.gov.ar/wsfev1/service.asmx?WSDL"
        Afip.cuit               = @bill.company.cuit || raise(Afip::NullOrInvalidAttribute.new, "Please set CUIT env variable.")
        Afip::AuthData.environment = :production
        Afip.environment 	      = :production
        #http://ayuda.egafutura.com/topic/5225-error-certificado-digital-computador-no-autorizado-para-acceder-al-servicio/
      else
        #TEST
        Afip.cuit = "20368642682"
        Afip.pkey = "#{Rails.root}/app/afip/facturacion.key"
        Afip.cert = "#{Rails.root}/app/afip/testing.crt"
        Afip.auth_url = "https://wsaahomo.afip.gov.ar/ws/services/LoginCms"
        Afip.service_url = "https://wswhomo.afip.gov.ar/wsfev1/service.asmx?WSDL"
        Afip::AuthData.environment = :test
      end
      Afip.default_concepto   = Afip::CONCEPTOS.key(@bill.company.concepto)
      Afip.default_documento  = "CUIT"
      Afip.default_moneda     = @bill.company.moneda.parameterize.underscore.gsub(" ", "_").to_sym
      Afip.own_iva_cond       = @bill.company.iva_cond.parameterize.underscore.gsub(" ", "_").to_sym
    end
  end
end
