module InvoiceManager
  class InvoiceDetailsCalculator < ApplicationService

    def initialize(*args)
      @invoice_details  = args[0][:invoice_details_attributes]
      @bonifications    = args[0][:bonifications_attributes]
      @tributes         = args[0][:tributes_attributes]
    end

    def call
      total_iva       = calcula_total_iva()
      total_neto      = calcula_total_neto()
      base_imponible  = calcula_base_imponible(total_neto)
      descuentos      = calcula_descuentos(total_iva)
      tributos        = calcula_tributos(base_imponible)
      total_venta     = calcula_total_final(total_iva, descuentos, tributos)

      resultado = {
        importe_neto: total_neto,
        importe_iva: total_iva,
        descuentos: descuentos,
        tributos: tributos,
        total_venta: total_venta
      }

      return resultado
    end

    private

    def calcula_total_neto
      @invoice_details
        .map { |idetail| idetail[:precio].to_f * ((100 - idetail[:bonificacion].to_f) / 100) * idetail[:cantidad].to_f }
        .inject(0) { |sum, n| sum + n }
        .round(2)
    end

    def calcula_total_iva
      @invoice_details
        .map{ |idetail| idetail[:subtotal].to_f }
        .inject(0) { |sum, n| sum + n }
        .round(2)
    end

    def calcula_base_imponible(total_neto)
      base_imponible    = aplica_descuentos(total_neto)
      return base_imponible
    end

    def aplica_descuentos(subtotal_a_bonificar)
      @bonifications.each do |bonification|
        subtotal_a_bonificar -= (subtotal_a_bonificar * (bonification[:alicuota].to_f / 100)).round(2)
      end
      return subtotal_a_bonificar
    end

    def calcula_descuentos(total_iva)
      descuento_total = 0
      @bonifications.each do |bonification|
        subtotal = (total_iva * ((100 - bonification[:alicuota].to_f).to_f / 100.to_f)).round(2)
        amount   = (total_iva - subtotal).round(2)
        descuento_total += amount
        total_iva       -= amount
      end

      return descuento_total.round(2)
    end

    def calcula_tributos(base_imponible)
      suma_tributos = 0
      @tributes.each do |tribute|
        importe       = (base_imponible.to_f * (tribute[:alicuota].to_f / 100)).round(2)
        suma_tributos += importe
      end

      return suma_tributos.round(2)
    end

    def calcula_total_final(total_iva, descuentos, tributos)
      total 	= total_iva - descuentos + tributos
      return total.round(2)
    end
  end
end
