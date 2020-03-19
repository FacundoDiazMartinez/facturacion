class BudgetDetail < ApplicationRecord
  belongs_to :product
  belongs_to :budget
  belongs_to :depot, optional: true

  validates_presence_of :price_per_unit, :product_name, :measurement_unit, :quantity, :subtotal, :iva_aliquot

	def product_code
	  product.nil? ? "" : product.code
	end
end
