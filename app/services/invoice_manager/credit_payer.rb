module InvoiceManager
  class CreditPayer < ApplicationService
    def initialize(invoice)
      @invoice = invoice
    end

    def call
      begin
      ActiveRecord::Base.transaction do
        if @invoice.real_total_left.round(2) > 0 && !@invoice.is_credit_note?
          pp monto_faltante = @invoice.real_total_left
          vector_documentos = []
          account_movements_records  = @invoice.client.account_movements.saldo_por_notas_de_credito
          account_movements_records += @invoice.client.account_movements.saldo_disponible_para_pagar
          raise(StandardError, "No hay monto disponible para asignar") if account_movements_records.empty?
          account_movements_records.sort_by(&:tiempo_de_confirmacion).each do |am|
            a_pagar = (am.amount_available >= @invoice.real_total_left) ? @invoice.real_total_left : am.amount_available
            ##movimientos de cuenta de recibos
            if am.receipt && am.receipt.confirmado?
              receipt = am.receipt
            	rd = ReceiptDetail.new(
                invoice_id: @invoice.id,
                receipt_id: receipt.id,
                total: a_pagar,
                total_payed_boolean: (@invoice.real_total_left - a_pagar) == 0
              )
            	if rd.save
                income_payment = IncomePayment.new(
  								type_of_payment: "6", #pago con cuenta corriente
  								payment_date: Date.today,
  								invoice_id: @invoice.id,
  								generated_by_system: true,
  								account_movement_id: am.id,
                  total: a_pagar
  							)
  							if income_payment.save
                  income_payment.set_total_pay_to_invoice
  								am.update_columns(
  									amount_available: am.amount_available - a_pagar
  								)
                  receipt.update_columns(
                    saved_amount_available: receipt.saved_amount_available - a_pagar
                  )
                  vector_documentos << "RX: #{receipt.number}"
  						  else
                  raise StandardError, "Pago: #{income_payment.errors.map{|e| e.message}.join(', ')}"
                end
              else
                raise StandardError, "Detalles del recibo: #{rd.errors}"
              end
            elsif am.invoice && am.invoice.is_credit_note?
              ## movimientos de cuenta nota de credito
              income_payment = IncomePayment.new(
                type_of_payment: "6", #pago con cuenta corriente
                payment_date: Date.today,
                invoice_id: @invoice.id,
                generated_by_system: true,
                account_movement_id: am.id,
                total: a_pagar
              )
              if income_payment.save
                am.update_columns(
                  amount_available: am.amount_available - a_pagar
                )
                vector_documentos << "NC: #{am.invoice.comp_number}"
              else
                raise StandardError, "Pago: #{income_payment.errors}."
              end
            end
            break if @invoice.reload.real_total_left == 0
          end
          ##
          if vector_documentos.any?
            return {
              resultado:  true,
              messages: [
                "Pago registrado"
              ]
            }
          else
            return {
              resultado:  false,
              messages: [
                "Pago no registrado"
              ]
            }
          end
        end
        return {
          resultado:  false,
          messages: [
            "Comprobante pagado previamente."
          ]
        }
      end
      ##
      rescue StandardError => error
        puts error.inspect
        return {
          resultado: false,
          messages: [
            "Pago no registrado. #{error.message}."
          ]
        }
      end
    end
  end
end
