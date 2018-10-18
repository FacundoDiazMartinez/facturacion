class Invoice < ApplicationRecord
  	belongs_to :client
  	belongs_to :sale_point
  	belongs_to :company
  	belongs_to :user

  	STATES = ["Pendiente", "Pagado", "Confirmado", "Anulado"]

  	#FILTROS DE BUSQUEDA
	  	def self.search_by_client name
	  		if name
	  			where("clients.name ILIKE ?", "%#{name}%")
	  		else
	  			all 
	  		end
	  	end

	  	def self.search_by_tipo tipo 
	  		if tipo
	  			where(tipo: tipo)
	  		else
	  			all 
	  		end
	 	 end

	  	def self.search_by_state state 
	  		if state
	  			where(state: state)
	  		else
	  			all 
	  		end
	  	end
  	#FILTROS DE BUSQUEDA


  	#FUNCIONES
  		def total_left
  			total.to_f - total_pay.to_f
  		end

  		def editable?
  			state == 'Confirmado' || state == 'Anulado'
  		end
  	#FUNCIONES

  	#ATRIBUTOS
  		def client_name
  			client.nil? ? "Consumidor Final" : client.name
  		end
  	#ATRIBUTOS
end
