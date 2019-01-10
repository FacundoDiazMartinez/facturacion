class BudgetDetail < ApplicationRecord
  belongs_to :product
  belongs_to :budget
  belongs_to :depot, optional: true

  after_save :adjust_reserved_stock, if: :saved_change_to_quantity?

  #ATRIBUTOS
  	def product_code
  		product.nil? ? "" : product.code
  	end
  #ATRIBUTOS

   #PROCEOS
	   	def adjust_reserved_stock
	      	if budget.reserv_stock
	      		dif = previous_changes["quantity"].last - previous_changes["quantity"].first
	        	product.reserve_stock(quantity: dif, depot_id: depot_id)
	      	end
	    end
   #PROCEOS

end
