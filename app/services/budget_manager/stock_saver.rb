module BudgetManager
  class StockSaver < ApplicationService
    attr_reader :budget

    def initialize(budget)
      @budget = budget
    end

    def call
      budget.budget_details.each { |detail| mueve_stock_a_reservado(detail) } if budget.reserv_stock
    end

    private

    def mueve_stock_a_reservado(detail)
      if detail.product.reserve_stock(quantity: detail.quantity, depot_id: detail.depot_id)
    end
  end
end
