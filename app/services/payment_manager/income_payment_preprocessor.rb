module PaymentManager
  class IncomePaymentPreprocessor < ApplicationService
    def initialize(income_payment)
      @income_payment = income_payment
    end

    def call
      if @income_payment.type_of_payment == "1"
        fee = Fee.find(@income_payment.card_payment.fee_id)
        @income_payment.card_payment.installments 						 = fee.quantity
        @income_payment.card_payment.interest_rate_percentage  = fee.percentage

        porcentaje_sobre_total = calcula_porcentaje_sobre_total()

        invoice_total_aux = @income_payment.invoice.total

        @income_payment.invoice.invoice_details.each do |invoice_detail|
          invoice_detail.price_per_unit += ((invoice_detail.price_per_unit * porcentaje_sobre_total) * ( @income_payment.card_payment.interest_rate_percentage / 100.to_f)).round(2)
          invoice_detail.subtotal       = (invoice_detail.price_per_unit * invoice_detail.quantity * (1 + Float(Afip::ALIC_IVA.map{|k,v| v if k == invoice_detail.iva_aliquot}.compact[0]))).round(2)
          invoice_detail.save
        end

        invoice = InvoiceManager::TotalsSetter.call(@income_payment.invoice)

        pp @income_payment.card_payment.subtotal
        pp invoice.total
        pp invoice_total_aux

        @income_payment.total = @income_payment.card_payment.subtotal + invoice.total - invoice_total_aux

        @income_payment.card_payment.fee_subtotal = (@income_payment.total.to_f / @income_payment.card_payment.installments).round(2)
        @income_payment.card_payment.total 				= @income_payment.total.round(2)

      end
      return @income_payment
    end

    private

    def calcula_porcentaje_sobre_total
      porcentaje = @income_payment.card_payment.subtotal / @income_payment.invoice.total.to_f

      return porcentaje
    end

  end
end
