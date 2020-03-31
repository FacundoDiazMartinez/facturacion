module DeliveryNoteManager
  class Confirmator < ApplicationService
    attr_accessor :delivery_note

    def initialize(delivery_note)
      @delivery_note = delivery_note
    end

    def call
      ActiveRecord::Base.transaction do
        if existen_productos_disponibles?
          extrae_productos_disponibles
          confirma_remito!
          factura_entregada! if todos_los_productos_entregados?
        end

        return delivery_note
      end
    end

    private

    def existen_productos_disponibles?
      disponibilidad = true
      delivery_note.delivery_note_details.includes(:depot, product: :stocks).each do |detail|
        disponible =  detail.product.stocks.where(depot_id: detail.depot_id).pluck(:quantity).inject(0, :+)
        if disponible < detail.quantity
          delivery_note.errors.add(:quantity, "[#{detail.product.name}]: Stock insuficiente. Disponible en [#{detail.depot.name}]: #{disponible} (#{detail.product.measurement_unit_name})")
          disponibilidad = false
        end
      end
      return disponibilidad
    end

    def extrae_productos_disponibles
      delivery_note.delivery_note_details.includes(:depot, product: :stocks).each do |detail|
        stock_reservado = detail.product.stocks.reservados.where(depot_id: detail.depot_id).first_or_initialize
        if stock_reservado.quantity < detail.quantity
          faltante_a_entregar        = detail.quantity.to_f - stock_reservado.quantity
          quita_de_stock_disponible!(detail.product, detail.depot_id, faltante_a_entregar)
          stock_reservado.quantity = 0
          stock_reservado.save
        else
          stock_reservado.quantity -= detail.quantity
          stock_reservado.save
        end
      end
    end

    def quita_de_stock_disponible!(product, depot_id, cantidad)
      stock_disponible           = product.stocks.disponibles.where(depot_id: depot_id).first_or_initialize
      stock_disponible.quantity -= cantidad
      stock_disponible.save
    end

    def confirma_remito!
      delivery_note.confirmar!
    end

    def todos_los_productos_entregados?
      entrega_completa = true
      invoice    = delivery_note.invoice
      invoice.invoice_details.each do |invoice_detail|
        cantidad_facturada = invoice_detail.quantity
        cantidad_entregada = DeliveryNoteDetail.includes(:delivery_note).where(delivery_notes: { state: "Finalizado", invoice_id: invoice.id }, product_id: invoice_detail.product_id).pluck(:quantity).inject(0, :+)

        if cantidad_facturada != cantidad_entregada
          entrega_completa = false
          break
        end
      end
      return entrega_completa
    end

    def factura_entregada!
      delivery_note.invoice.entregado!
    end
  end
end
