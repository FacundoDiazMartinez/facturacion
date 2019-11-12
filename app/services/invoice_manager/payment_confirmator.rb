module InvoiceManager
  class PaymentConfirmator < ApplicationService
    def initialize(invoice)
      @invoice = invoice
    end

    def call
      @invoice.income_payments.where(generated_by_system: false).each do |payment|
        payment.update(confirmed: true)
        payment.save_daily_cash_movement
      end
      return true
    end

  end
end
