module TransferRequestManager
  class Distributor < ApplicationService
    attr_accessor :transfer_request

    def initialize(transfer_request)
      @transfer_request = transfer_request
    end

    def call
      ActiveRecord::Base.transaction do
        if existencias_en_deposito_de_origen?
          extraer_productos_de_origen
          transferencia_en_transito!
        end

        return transfer_request
      end
    end

    private

    def existencias_en_deposito_de_origen?
      disponibilidad = true
      transfer_request.transfer_request_details.includes(product: :stocks).each do |detail|
        stock_disponible = detail.product.stocks.disponibles.where(depot_id: transfer_request.from_depot_id).first_or_initialize
        if stock_disponible.quantity < detail.quantity
          agrega_error_por_disponibilidad(detail, stock_disponible.quantity)
          disponibilidad = false
        end
      end
      return disponibilidad
    end

    def extraer_productos_de_origen
      transfer_request.transfer_request_details.includes(product: :stocks).each do |detail|
        stock_disponible = detail.product.stocks.disponibles.where(depot_id: transfer_request.from_depot_id).first
        stock_disponible.quantity -= detail.quantity
        stock_disponible.save
      end
    end

    def transferencia_en_transito!
      @transfer_request.en_camino!
    end

    def agrega_error_por_disponibilidad(detail, cantidad_disponible)
      transfer_request.errors.add(:stock, "[#{detail.product.name}]: Stock insuficiente. Disponible en [#{transfer_request.sender.name}]: #{cantidad_disponible} (#{detail.product.measurement_unit_name})")
    end
  end
end
