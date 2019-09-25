module ReceiptManager
  class Confirmator < ApplicationService

    def initialize(receipt)
      @receipt = receipt
    end

    def call
      begin
        confirma_movimiento_de_cuenta()
        @receipt.saved_amount_available = @receipt.account_movement.amount_available
        @receipt.state                  = "Finalizado"
        @receipt.save
      rescue StandardError => error
        pp error.inspect
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
