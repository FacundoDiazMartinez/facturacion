module InvoiceManager
  class Confirmator < ApplicationService

    def initialize(invoice)
      @invoice = invoice
    end

    def call
      ActiveRecord::Base.transaction do
        verifica_cliente_con_cuenta_corriente()

        AccountMovementGenerator.call(@invoice) if @invoice.on_account?
        ReceiptGenerator.call(@invoice) if @invoice.total_pay > 0

        comprobante = AfipGateway.call(@invoice)
        comprobante.authorize
        if comprobante.authorized?
  				update_invoice_data(comprobante)
          IvaBookGenerator.call(@invoice)
        else
  				display_confirmation_errors(comprobante)
        end
      rescue ActiveRecord::RecordInvalid => exception
        @invoice.errors.add("Comprobante no confirmado.1", exception.message)
        raise ActiveRecord::Rollback
      rescue StandardError => error
        @invoice.errors.add("Comprobante no confirmado.2", error.message)
        raise ActiveRecord::Rollback
      rescue NoMethodError => error
        @invoice.errors.add("Comprobante no confirmado.3", error.message)
        raise ActiveRecord::Rollback
      end
    end

    private

    def update_invoice_data(invoice)
      response = @invoice.update(
        cae:            invoice.response.cae,
        cae_due_date:   invoice.response.cae_due_date,
        cbte_fch:       invoice.response.cbte_fch.to_date,
        authorized_on:  invoice.response.authorized_on.to_time,
        comp_number:    invoice.response.cbte_hasta.to_s.rjust(8,padstr= '0'),
        imp_tot_conc:   invoice.response.imp_tot_conc,
        imp_op_ex:      invoice.response.imp_op_ex,
        imp_trib:       invoice.response.try(:imp_trib) || 0.0,
        imp_neto:       invoice.response.imp_neto,
        imp_iva:        invoice.response.try(:imp_iva) || 0,
        imp_total:      invoice.response.imp_total,
        state:          "Confirmado"
      )
      @invoice.activate_commissions
    end

    def display_confirmation_errors(bill)
      raise ActiveRecord::Rollback, "Servidor AFIP: #{bill.response.errores[:msg]}." unless bill.response.errores.nil?
      unless bill.response.observaciones.nil?
        if bill.response.observaciones.any?
          if bill.response.observaciones[:obs].class == Hash
            raise ActiveRecord::Rollback, "Servidor AFIP: #{bill.response.observaciones[:obs][:msg]}."
          elsif bill.response.observaciones[:obs].class == Array
            raise ActiveRecord::Rollback, "Servidor AFIP: #{bill.response.observaciones[:obs].split('. ')}"
          end
        end
      end
      raise ActiveRecord::Rollback
    end

    def verifica_cliente_con_cuenta_corriente
      if @invoice.is_invoice?  && (@invoice.total_left > 0)
        if !@invoice.client.valid_for_account?
          raise StandardError, "Cliente inhabilitado para Cuenta Corriente. Ingrese pagos por la totalidad de la factura."
        elsif !@invoice.on_account?
          raise StandardError, "Comprobante no confirmado. Ingrese pagos por la totalidad de la factura."
        end
      end
    end
  end
end
