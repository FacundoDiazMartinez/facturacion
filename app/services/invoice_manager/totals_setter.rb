module InvoiceManager
  class TotalsSetter < ApplicationService
    ## calcula los totales de una factura (total y pagado)
    ## debe ser utilizado antes de guardar una factura

    def initialize(invoice)
      @invoice = invoice
    end

    def call
      pp @invoice.invoice_details

      calcula_base_imponible()
      calcula_descuentos()
      calcula_tributos()
      calcula_pagos()
      calcula_total_final()

      return @invoice
    end

    private

    def calcula_base_imponible
      suma_conceptos_sin_iva  = subotal_conceptos_sin_iva()
      descuentos_aplicados    = aplica_descuentos(suma_conceptos_sin_iva)
      @invoice.base_imponible = descuentos_aplicados
      return true
    end

    def calcula_descuentos
      conceptos_con_iva = subtotal_conceptos_con_iva()
      descuento_total = 0
      @invoice.bonifications.each do |bonification|
        bonification.subtotal = (conceptos_con_iva * ((100 - bonification.percentage).to_f / 100.to_f)).round(2)
        bonification.amount   = (conceptos_con_iva - bonification.subtotal).round(2)
        descuento_total       += bonification.amount
        conceptos_con_iva     -= bonification.amount
      end

      @invoice.bonification = descuento_total.round(2)
      return true
    end

    def calcula_tributos
      suma_tributos = 0
      @invoice.tributes.each do |tribute|
        tribute.base_imp  = @invoice.base_imponible.to_f.round(2)
        tribute.importe   = (@invoice.base_imponible.to_f * (tribute.alic / 100)).round(2)
        suma_tributos     += tribute.importe
      end

      @invoice.total_tributos = suma_tributos.round(2)
      return true
    end

    def calcula_pagos
      monto_pagado = @invoice.income_payments
        .reject(&:marked_for_destruction?)
        .pluck(:total)
        .inject(0) { |sum, n| sum + n }

      @invoice.total_pay = monto_pagado.round(2)

      @invoice.income_payments
        .reject(&:marked_for_destruction?)
        .each do |payment|
          if payment.type_of_payment == "1"
            payment.total = payment.card_payment.total
          end
        end
    end

    def calcula_total_final
      @invoice.total 	= subtotal_conceptos_con_iva().round(2) - @invoice.bonification + @invoice.total_tributos
    end

    def subotal_conceptos_sin_iva
      @invoice.invoice_details
        .reject(&:marked_for_destruction?)
        .map { |idetail| idetail.price_per_unit * ((100 - idetail.bonus_percentage) / 100) * idetail.quantity }
        .inject(0) { |sum, n| sum + n }
    end

    def subtotal_conceptos_con_iva
      @invoice.invoice_details
        .reject(&:marked_for_destruction?)
        .pluck(:subtotal)
        .inject(0) { |sum, n| sum + n }
    end

    def aplica_descuentos(subtotal_a_bonificar)
      @invoice.bonifications.reject(&:marked_for_destruction?).each do |bonification|
        subtotal_a_bonificar -= (subtotal_a_bonificar * (bonification.percentage.to_f / 100)).round(2)
      end
      return subtotal_a_bonificar
    end
  end
end
