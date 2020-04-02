module ArrivalNoteManager
  class Confirmator < ApplicationService
    attr_accessor :arrival_note

    def initialize(arrival_note)
      @arrival_note = arrival_note
    end

    def call
      ActiveRecord::Base.transaction do
        aumenta_stock_disponible
        remito_confirmado!
        return arrival_note
      end
    end

    private

    def aumenta_stock_disponible
      arrival_note.arrival_note_details.each do |detail|
        stock_disponible = detail.product.stocks.disponibles.first_or_initialize
        stock_disponible.quantity += detail.quantity
        stock_disponible.save!
      end
    end

    def remito_confirmado!
      arrival_note.confirmado!
    end
  end
end
