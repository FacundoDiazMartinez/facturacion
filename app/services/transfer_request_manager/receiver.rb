module TransferRequestManager
  class Receiver < ApplicationService
    attr_accessor :transfer_request

    def initialize(transfer_request)
      @transfer_request = transfer_request
    end

    def call
      ActiveRecord::Base.transaction do
        aumentar_disponibilidades_end_destino
        remito_finalizado!
      end
    end

    private

    def aumentar_disponibilidades_end_destino
      transfer_request.transfer_request_details.each do |detail|
        stock_disponible = detail.product.stocks.disponibles.where(depot_id: transfer_request.to_depot_id).first_or_initialize

        stock_disponible.quantity += detail.quantity
        stock_disponible.save!
      end
    end

    def remito_finalizado!
      transfer_request.confirmar!
    end

  end
end
