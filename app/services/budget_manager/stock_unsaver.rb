module BudgetManager
  class StockUnsaver < ApplicationService
    attr_reader :budget

    def initialize(budget)
      @budget = budget
    end

    def call
      if budget.reserv_stock
        
      end
    end

    private

    def method
      # code
    end
  end
end
