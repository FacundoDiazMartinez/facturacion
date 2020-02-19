module ProductManager
  class DepotsExchangeReceiver < ApplicationService
    def initialize(transfer_request, user)
      @transfer_request = transfer_request
      @user             = user
    end

    def call
      ActiveRecord::Base.transaction do
        enviar_stock_a_deposito_de_destino()
        @transfer_request.update(received_at: Time.now, received_by: @user.id, state: "Recibido")
      rescue ActiveRecord::RecordInvalid => exception
        puts exception.inspect
        raise ActiveRecord::Rollback
      rescue StandardError => error
        puts error.inspect
        raise ActiveRecord::Rollback
      end
    end

    private
    def enviar_stock_a_deposito_de_destino
      @transfer_request.transfer_request_details.each do |detail|
        s = detail.product.stocks.where(depot_id: @transfer_request.to_depot_id, state: "Disponible").first_or_initialize
        s.quantity = s.quantity.to_f + detail.quantity.to_f
        s.save
        detail.product.set_available_stock
      end
    end

  end
end
