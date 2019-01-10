class SalesFile < ApplicationRecord
  belongs_to :company
  belongs_to :client
  belongs_to :responsable, class_name: "User", foreign_key: "responsable_id"

  #FILTROS DE BUSQUEDA
  	def self.search_by_user user
  		if !name.nil?
        	joins(:responsable).where("LOWER(users.first_name ||' ' || users.last_name) LIKE LOWER(?)", "%#{name}%")
	    else
	        all 
	    end
  	end

    def self.search_by_state state
      if !state.blank?
        where(state: state)
      else
        all
      end
    end

    def self.search_by_date date
      if date.blank?
        date = Date.today
      end
      find_by_date(date)
    end
  #FILTROS DE BUSQUEDA
end
