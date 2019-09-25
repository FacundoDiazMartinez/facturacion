module ReceiptManager
  class Confirmator < ApplicationService

    def initialize(receipt)
      @receipt = receipt
    end

    def call
      ActiveRecord::Base.transaction do
        confirma_movimiento_de_cuenta()
        @receipt.account_movement.reload
        @receipt.saved_amount_available = @receipt.account_movement.amount_available
        pp @receipt.saved_amount_available
        @receipt.state                  = "Finalizado"
        @receipt.save
      rescue ActiveRecord::RecordInvalid => exception
        @receipt.errors.add("Error al confirmar", exception)
        raise ActiveRecord::Rollback
      rescue StandardError => error
        pp error.inspect
        raise ActiveRecord::Rollback
      end
    end

    private

    def confirma_movimiento_de_cuenta
      AccountMovement.unscoped do
        @receipt.account_movement.confirmar!
      end
    end
  end
end
