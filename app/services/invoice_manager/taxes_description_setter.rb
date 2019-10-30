module InvoiceManager
  class TaxesDescriptionSetter < ApplicationService
    TRIBUTOS = {
        "1" => "Impuestos nacionales",
        "2" => "Impuestos provinciales",
        "3" => "Impuestos municipales",
        "4" => "Impuestos Internos",
        "99" => "Otro",
        "5" => "IIBB",
        "6" => "Percepción de IVA",
        "7" => "Percepción de IIBB",
        "8" => "Percepciones por Impuestos Municipales",
        "9" => "Otras Percepciones",
        "13" => "Percepción de IVA a no Categorizado",
   }

    def initialize(tax)
      @tax = tax
    end

    def call
      return TRIBUTOS[@tax.afip_id]
    end

  end
end
