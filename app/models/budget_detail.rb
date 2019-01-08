class BudgetDetail < ApplicationRecord
  belongs_to :product
  belongs_to :budget
  belongs_to :depot, optional: true

  #ATRIBUTOS
  	def product_code
  		product.nil? ? "" : product.code
  	end
  #ATRIBUTOS

end
