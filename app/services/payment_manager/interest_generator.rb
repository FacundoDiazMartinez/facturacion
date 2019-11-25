module PaymentManager
  class InterestGenerator < ApplicationService

    def initialize(income_payment)
      @invoice        = income_payment.invoice
      @card_payment   = income_payment.card_payment
    end

    def call
      incrementar_precio_detalles_por_intereses()
    end

    private

    def incrementar_precio_detalles_por_intereses
      @invoice.invoice_details.each do |invoice_detail|
        invoice_detail.price_per_unit = (invoice_detail.price_per_unit * (1 + @card_payment.interest_rate_percentage / 100.to_f)).round(2)
        invoice_detail.save
      end
    end
  end
end
