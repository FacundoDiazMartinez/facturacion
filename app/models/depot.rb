class Depot < ApplicationRecord
  belongs_to :company
  has_many   :stocks


  #FILTROS DE BUSQUEDA
  	def self.search_by_name name
	      	if !name.nil?
	        	where("LOWER(name) LIKE LOWER(?)", "%#{name}%")
	      	else
	        	all 
	      	end
	    end

	    def self.search_by_state state
	      	case state
	      	when "Disponible"
	      		where(filled: false)
	      	when "LLeno"
	      		where(filled: true)
	      	when ""
	      		all
	      	else
	      		all
	      	end
	    end
	#FILTROS DE BUSQUEDA
end
