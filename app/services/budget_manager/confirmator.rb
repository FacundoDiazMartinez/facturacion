module BudgetManager
  class Confirmator < ApplicationService
    attr_accessor :budget

    def initialize(budget)
      @budget = budget
    end

    def call
      if presupuesto_reserva_stock?
        if stock_suficiente?
          reservar_stock!
          confirmar_presupuesto!
        else
          asigna_error_por_disponibilidad
        end
      else
        confirmar_presupuesto!
      end
      return budget
    end

    private

    def presupuesto_reserva_stock?
      budget.reserv_stock
    end

    def stock_suficiente?
      budget.budget_details.each do |detail|
        stock = Stock.disponibles.where(product_id: detail.product_id, depot_id: detail.depot_id).first_or_create
        return false if stock.quantity < detail.quantity
      end
      return true
    end

    def reservar_stock!
      budget.budget_details.each do |detail|
        stocks = Stock.where(product_id: detail.product_id, depot_id: detail.depot_id)
        stock_disponible = stocks.disponibles.first_or_create
        stock_reservado = stocks.reservados.first_or_create

        stock_disponible.quantity -= detail.quantity
        stock_reservado.quantity  += detail.quantity

        stock_disponible.save && stock_reservado.save
      end
    end

    def confirmar_presupuesto!
      budget.confirmado!
    end

    def asigna_error_por_disponibilidad
      budget.errors.add("Baja disponibilidad", "El stock disponible es insuficiente para realizar la reserva.")
    end
  end
end
