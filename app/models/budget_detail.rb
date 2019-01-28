class BudgetDetail < ApplicationRecord
  belongs_to :product
  belongs_to :budget
  belongs_to :depot, optional: true

  after_validation :adjust_reserved_stock

  #ATRIBUTOS
  	def product_code
  		product.nil? ? "" : product.code
  	end
  #ATRIBUTOS

   #PROCEOS
	   	def adjust_reserved_stock
	      	if budget.reserv_stock
            if new_record?
	      		 dif = quantity - quantity_was + 1
            else
              dif = quantity - quantity
            end
	        	product.reserve_stock(quantity: dif, depot_id: depot_id)
	      	end
	    end
   #PROCEOS

end
