module InvoiceManager
  class ExpirationSetter < ApplicationService
    LIMITE_DE_VENCIMIENTO = 30

    def initialize(invoice)
      @inovice = invoice
    end

    def call
      #code
    end

    private

    def method
      #code
    end
  end
end
#
# def update_expired
#   if (Date.today - self.cbte_fch.to_date).to_i >= 30 && (self.total - self.total_pay > 0)
#     self.expired = true
#   end
# end
# handle_asynchronously :update_expired, :run_at => Proc.new { |invoice| invoice.cbte_fch.to_date + 30.days }
