module DeliveryNoteManager
  class Cancelator < ApplicationService
    attr_accessor :delivery_note

    def initialize(delivery_note)
      @delivery_note = delivery_note
    end

    def call
      ActiveRecord::Base.transaction do
        unless factura_anulada?
          repone_existencias_a_stock_disponible
          anula_remito!
          factura_no_entregada!
        end
        return delivery_note
      end
    end

    private

    def factura_anulada?
      if delivery_note.invoice.anulado?
        delivery_note.errors.add(:invoice, "El comprobante asociado se encuentra en estado [ANULADO].")
        return true
      end
      false
    end

    def repone_existencias_a_stock_disponible
      delivery_note.delivery_note_details.includes(product: :stocks).each do |detail|
        reserved_stock  = detail.product.stocks.where(depot_id: detail.depot_id, state: "Reservado").first_or_initialize
        reserved_stock.quantity += detail.quantity
        reserved_stock.save
      end
    end

    def anula_remito!
      delivery_note.anular!
    end

    def factura_no_entregada!
      delivery_note.invoice.no_entregado!
    end
  end
end
