module ProductManager
  class DepotsExchangeSender < ApplicationService
    def initialize(transfer_request, user)
      @transfer_request = transfer_request
      @user             = user
    end

    def call
      ActiveRecord::Base.transaction do
        resultado = validar_existencias_en_deposito_de_origen()
        unless resultado
          raise ActiveRecord::Rollback
          return false
        end
        @transfer_request.update(sended_at: Time.now, sended_by: @user.id, state: "Enviado")
        return true
      rescue ActiveRecord::RecordInvalid => exception
        puts exception.inspect
        raise ActiveRecord::Rollback
        return false
      rescue StandardError => error
        puts error.inspect
        raise ActiveRecord::Rollback
        return false
      end
    end

    private
    def validar_existencias_en_deposito_de_origen
      @transfer_request.transfer_request_details.each do |detail|
        s = detail.product.stocks.where(depot_id: @transfer_request.from_depot_id, state: "Disponible").first
        s.quantity = s.quantity.to_f - detail.quantity.to_f
        if (s.quantity >= 0)
          s.save
          detail.product.set_available_stock
        else
          return false
        end
      end
      return true
    end
  end
end
