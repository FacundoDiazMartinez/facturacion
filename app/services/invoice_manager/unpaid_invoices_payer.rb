module InvoiceManager
  class UnpaidInvoicesPayer < ApplicationService

    def initialize(client)
      @client = client
    end

    def call
      begin
        @client.account_movements.saldo_disponible_para_pagar.each do |am|
          am.receipt.receipt_details.order(:id).each do |rd|
            invoice = rd.invoice
            unless invoice.is_credit_note?
              if invoice.real_total_left.to_f > 0
                income_payment = nuevo_pago_a_cuenta_corriente(invoice, am)
                if income_payment.save
                  am.update_columns(
                    amount_available: am.amount_available - income_payment.total
                  )
                  rd.update_columns(
                    total: income_payment.total,
                    total_payed_boolean: (invoice.real_total_left - income_payment.total) == 0
                  )
                else
                  raise StandardError, income_payment.errors
                end
              end
              break if am.amount_available == 0
            end
          end
          break if am.amount_available == 0
        end
      rescue StandardError => error
        puts error.inspect
      end
    end

    private

    def nuevo_pago_a_cuenta_corriente(invoice, am)
      income_payment = IncomePayment.new(
        type_of_payment:       "6", #pago con cuenta corriente
        payment_date:          Date.today,
        invoice_id:            invoice.id,
        generated_by_system:   true,
        account_movement_id:   am.id
      )
      income_payment.total = (am.amount_available.to_f >= invoice.real_total_left.to_f) ? invoice.real_total_left.to_f : am.amount_available.to_f
      return income_payment
    end
  end
end
