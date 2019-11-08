module CompanyManager
  class DefaultTaxesGetter < ApplicationService
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

    def call
      impuestos_registrados
    end

    private

    def impuestos_registrados
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
