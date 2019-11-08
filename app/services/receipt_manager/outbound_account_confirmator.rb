module ReceiptManager
  class OutboundAccountConfirmator < ApplicationService
    def initialize(receipt)
      @receipt = receipt
    end

    def call
      ActiveRecord::Base.transaction do
        confirma_movimiento_de_cuenta(@receipt)

        @receipt.update_columns(
          saved_amount_available: 0,
          state: "Finalizado"
        )

      rescue ActiveRecord::RecordInvalid => exception
        @receipt.errors.add("Error al confirmar", exception)
        raise ActiveRecord::Rollback
      rescue StandardError => error
        puts error.inspect
        raise ActiveRecord::Rollback
      end
    end

    private

    def confirma_movimiento_de_cuenta(recibo)
      AccountMovement.unscoped do
        recibo.account_movement.account_movement_payments.each{ |payment| payment.confirmar }
        recibo.account_movement.total             = recibo.total
        recibo.account_movement.amount_available  = 0
        recibo.account_movement.saldo             = 0
        recibo.account_movement.save!
      end
    end
  end
end
