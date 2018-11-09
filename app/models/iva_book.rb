class IvaBook < ApplicationRecord
  belongs_to :invoice
  belongs_to :purchase_invoice


  #FILTROS DE BUSQUEDA
  	def self.find_by_period from, to
  		if from && to
  			where(date: from...to)
  		else
  			all 
  		end
  	end
  #FILTROS DE BUSQUEDA
end
