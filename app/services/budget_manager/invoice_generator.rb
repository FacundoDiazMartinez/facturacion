module BudgetManager
  class InvoiceGenerator < ApplicationService
    attr_accessor :budget

    def initialize(budget)
      @budget = budget
    end

    def call
      invoice = asocia_detalles_a_factura(genera_nueva_factura_venta)
    end

    private

    def genera_nueva_factura_venta
      invoice = Invoice.new.tap do |invoice|
        invoice.client_id     = budget.client_id
        invoice.company_id    = budget.client_id
        invoice.sale_point_id = budget.company.sale_points.first.id
        invoice.user_id       = budget.user_id
        invoice.total         = budget.total
        invoice.budget_id     = budget.id
      end
      return invoice
    end

    def asocia_detalles_a_factura(invoice)
      budget.budget_details.each do |bd|
        detail = invoice.invoice_details.build(
          quantity: bd.quantity,
          measurement_unit: bd.measurement_unit,
          price_per_unit: bd.price_per_unit,
          bonus_percentage: bd.bonus_percentage,
          bonus_amount: bd.bonus_amount,
          iva_aliquot: bd.iva_aliquot,
          iva_amount: bd.iva_amount,
          subtotal: (bd.price_per_unit * bd.quantity ) + bd.iva_amount - bd.bonus_amount,
          depot_id: bd.depot_id
        )
        if !bd.product.blank?
          detail.product = bd.product
        else
          detail.product = Product.new(name: bd.product_name)
        end
      end
      return invoice
    end
  end
end
