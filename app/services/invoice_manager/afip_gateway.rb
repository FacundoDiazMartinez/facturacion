module InvoiceManager
  class AfipGateway < ApplicationService

    def initialize(comprobante)
      @invoice = comprobante
    end

    def call
      establece_constantes
      comprobante = Afip::Bill.new(
        net:            suma_montos_netos_con_descuento,
        doc_num:        0,
        sale_point:     @invoice.sale_point.name,
        documento:      Afip::DOCUMENTOS.key(@invoice.client.document_type),
        moneda:         @invoice.company.moneda.parameterize.underscore.gsub(" ", "_").to_sym,
        iva_cond:       @invoice.client.iva_cond.parameterize.underscore.gsub(" ", "_").to_sym,
        concepto:       @invoice.concepto,
        ivas:           vector_de_iva_con_descuento,
        cbte_type:      @invoice.cbte_tipo,
        fch_serv_desde: @invoice.fch_serv_desde,
        fch_serv_hasta: @invoice.fch_serv_hasta,
        due_date:       @invoice.fch_vto_pago,
        # tributos:       @invoice.tributes.map{|t| [t.afip_id, t.desc, t.base_imp, t.alic, t.importe]},
        tributos:       [],
        cant_reg:       1,
        no_gravado:     no_gravado,
        exento:         exento,
        # otros_imp:      otros_imp
        otros_imp:      0
      )
      comprobante.doc_num = invoice_client_document

      return comprobante
    end

    private

    def establece_constantes
      if @invoice.company.environment == "production"
        #PRODUCCION
        Afip.pkey               = "#{Rails.root}/app/afip/facturacion.key"
        Afip.cert               = "#{Rails.root}/app/afip/produccion.crt"
        Afip.auth_url           = "https://wsaa.afip.gov.ar/ws/services/LoginCms"
        Afip.service_url        = "https://servicios1.afip.gov.ar/wsfev1/service.asmx?WSDL"
        Afip.cuit               = @invoice.company.cuit || raise(Afip::NullOrInvalidAttribute.new, "Please set CUIT env variable.")
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
      Afip.default_concepto   = Afip::CONCEPTOS.key(@invoice.company.concepto)
      Afip.default_documento  = "CUIT"
      Afip.default_moneda     = @invoice.company.moneda.parameterize.underscore.gsub(" ", "_").to_sym
      Afip.own_iva_cond       = @invoice.company.iva_cond.parameterize.underscore.gsub(" ", "_").to_sym
    end

    def vector_de_iva_con_descuento
      i = Array.new
      iva_hash = @invoice.invoice_details
        .group_by{ |invoice_detail| invoice_detail.iva_aliquot }
        .map{ |aliquot, inv_det| {
          aliquot: aliquot,
          net_amount: inv_det.sum{ |id| aplica_descuentos_globales(id.neto) },
          iva_amount: inv_det.sum{ |s| aplica_descuentos_globales(s.iva_amount) }
          }
        }

      iva_hash.each do |iva|
        i << [ iva[:aliquot], iva[:net_amount].round(2), iva[:iva_amount].round(2) ]
      end
      return i
    end

    def no_gravado
      @invoice.invoice_details.where(iva_aliquot: "01").sum(:subtotal).to_f.round(2)
    end

    def exento
      @invoice.invoice_details.where(iva_aliquot: "02").sum(:subtotal).to_f.round(2)
    end

    def otros_imp
      @invoice.tributes.sum(:importe).to_f.round(2)
    end

    def suma_montos_netos_con_descuento
      @invoice.invoice_details
        .where(iva_aliquot: ["03", "04", "05", "06"])
        .inject(0) {|sum, detail| sum + aplica_descuentos_globales(detail.neto) }.round(2)
    end

    def aplica_descuentos_globales(importe)
      @invoice.bonifications.each do |bonification|
        importe -= importe * (bonification.percentage / 100)
      end
      return importe
    end

    def invoice_client_document
      if @invoice.client.document_type == '99'
        0
      else
        @invoice.client.document_number
      end
    end
  end
end
