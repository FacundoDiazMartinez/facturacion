module BudgetManager
  class Cancelator < ApplicationService
    attr_reader :budget

    def initialize(budget)
      @budget = budget
    end

    def call
      retornar_stock! if reserva_stock?
      anular_presupuesto!
      return budget
    end

    private

    def reserva_stock?
      budget.reserv_stock
    end

    def retornar_stock!
      budget.budget_details.each do |detail|
        stocks = Stock.where(product_id: detail.product_id, depot_id: detail.depot_id)
        stock_disponible = stocks.disponibles.first_or_create
        stock_reservado = stocks.reservados.first_or_create

        stock_disponible.quantity += detail.quantity

        reservado = stock_reservado.quantity - detail.quantity
        if reservado > 0
          stock_reservado.quantity  = reservado
        else
          stock_reservado.quantity  = 0
        end

        stock_disponible.save && stock_reservado.save
      end
    end

    def anular_presupuesto!
      budget.anulado!
    end
  end
end
