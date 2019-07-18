module InvoiceManager
  class Confirmator < ApplicationService

    def initialize(invoice)
      @invoice = invoice
    end

    def call
      begin
        comprobante = InvoiceManager::AfipGateway.call(@invoice)
        comprobante.authorize
        if comprobante.authorized?
  				update_invoice_data(comprobante)
        else
  				display_confirmation_errors(comprobante)
        end
        return comprobante
      rescue StandardError => error
        @invoice.errors.add("Comprobante no confirmado.", error.message)
        puts error.inspect
      rescue NoMethodError => error
        puts "NoMethodError: #{error.inspect}"
      end
    end

    private
    def update_invoice_data(invoice)
      response = @invoice.update(
        cae: invoice.response.cae,
        cae_due_date: invoice.response.cae_due_date,
        cbte_fch: invoice.response.cbte_fch.to_date,
        authorized_on: invoice.response.authorized_on.to_time,
        comp_number: invoice.response.cbte_hasta.to_s.rjust(8,padstr= '0'),
        imp_tot_conc: invoice.response.imp_tot_conc,
        imp_op_ex: invoice.response.imp_op_ex,
        imp_trib: invoice.response.try(:imp_trib) || 0.0,
        imp_neto: invoice.response.imp_neto,
        imp_iva: invoice.response.try(:imp_iva) || 0,
        imp_total: invoice.response.imp_total,
        state: "Confirmado"
      )
      @invoice.activate_commissions
      if response && @invoice.is_credit_note? && !@invoice.associated_invoice.nil?
        if @invoice.invoice.credit_notes.sum(:total).round(2) == @invoice.invoice.total.round(2)
          @invoice.invoice.update_column(:state, "Anulado")
        else
          @invoice.invoice.update_column(:state, "Anulado parcialmente")
        end
      end
    end

    def display_confirmation_errors(bill)
      raise StandardError, "Servidor AFIP: #{bill.response.errores[:msg]}." unless bill.response.errores.nil?
      unless bill.response.observaciones.nil?
        if bill.response.observaciones.any?
          if bill.response.observaciones[:obs].class == Hash
            raise StandardError, "Servidor AFIP: #{bill.response.observaciones[:obs][:msg]}"
          elsif bill.response.observaciones[:obs].class == Array
            raise StandardError, "Servidor AFIP: #{bill.response.observaciones[:obs].split('. ')}"
          end
        end
      end
    end
  end
end