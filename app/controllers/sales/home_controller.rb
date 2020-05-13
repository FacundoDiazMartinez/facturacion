class Sales::HomeController < ApplicationController
  def index
    @facturas_anual = current_company.invoices.confirmados.where(created_at: Date.today.beginning_of_year..Date.today.end_of_year)
    @facturas_mensual = current_company.invoices.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month)

    @presupuestos_anual = current_company.budgets.confirmados.where(created_at: Date.today.beginning_of_year..Date.today.end_of_year)
    @presupuestos_mensual = current_company.budgets.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month)
  end
end
