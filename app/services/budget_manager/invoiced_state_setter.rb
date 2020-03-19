module BudgetManager
  class InvoicedStateSetter < ApplicationService
    attr_accessor :budget

    def initialize(budget)
      @budget = budget
    end

    def call
      @budget.facturado!
    end
  end
end
