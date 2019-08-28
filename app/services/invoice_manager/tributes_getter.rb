module InvoiceManager
  class TributesGetter
    attr_reader :get_tributes
    attr_reader :get_default_tributes

    TRIBUTOS = [
     ["Impuestos nacionales", "1"],
     ["Impuestos provinciales", "2"],
     ["Impuestos municipales", "3"],
     ["Impuestos Internos", "4"],
     ["Otro", "99"],
     ["IIBB", "5"],
     ["Percepción de IVA", "6"],
     ["Percepción de IIBB", "7"],
     ["Percepciones por Impuestos Municipales", "8"],
     ["Otras Percepciones", "9"],
     ["Percepción de IVA a no Categorizado", "13"]
    ]

    def initialize(company)
      @company = company
    end

    def get_tributes
      Afip.default_concepto   = Afip::CONCEPTOS.key(@company.concepto)
      Afip.default_documento  = "CUIT"
      Afip.default_moneda     = @company.moneda.parameterize.underscore.gsub(" ", "_").to_sym
      Afip.own_iva_cond       = @company.iva_cond.parameterize.underscore.gsub(" ", "_").to_sym
      Afip::AuthData.environment = :test
      begin
        Afip::Bill.get_tributos.map{|t| [t[:desc], t[:id]]}
      rescue
        TRIBUTOS
      end
    end

    def get_default_tributes
      tributes = []
      @company.default_tributes.each do |trib|
        tributes << Tribute.new(
          afip_id:   trib.tribute_id,
          desc:      TRIBUTOS.map { |t| t.first if t.last == trib.tribute_id.to_s }.compact.first,
          alic:      trib.default_aliquot
        )
      end
      tributes
    end
  end
end
