class BudgetDetail < ApplicationRecord
  belongs_to :product
  belongs_to :budget
  belongs_to :depot, optional: true

  validates_presence_of :budget, :product, :price_per_unit, :product_name, :measurement_unit, :quantity, :subtotal, :iva_aliquot
  validates_uniqueness_of :product, scope: [:budget, :depot], message: "El mismo producto y depósito fueron seleccionados previamente para este presupuesto."

	def product_code
	  product.nil? ? "" : product.code
	end
end
