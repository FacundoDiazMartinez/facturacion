module TransferRequestManager
  class Cancelator < ApplicationService
    attr_accessor :transfer_request

    def initialize(transfer_request)
      @transfer_request = transfer_request
    end

    def call
      ActiveRecord::Base.transaction do
        if transfer_request.en_camino?
          repone_existencias_disponibles!
          remito_pendiente!
        end
      end
    end

    private

    def repone_existencias_disponibles!
      transfer_request.transfer_request_details.includes(product: :stocks).each do |detail|
        stock_disponible = detail.product.stocks.disponibles.where(depot_id: transfer_request.from_depot_id).first
        stock_disponible.quantity += detail.quantity
        stock_disponible.save
      end
    end

    def remito_pendiente!
      transfer_request.pendiente!
    end
  end
end
