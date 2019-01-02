class DailyCash < ApplicationRecord
  belongs_to :company
  belongs_to :user
  has_many   :daily_cash_movements

  after_save :create_initial_movement, on: :create

  #FILTROS DE BUSQUEDA
  	def self.search_by_date date
		if !date.blank?
			where(date: date)
		else
			all 
		end  		
  	end

  	def self.search_by_user user
  		if !user.blank?
  			where(user_id: user)
  		else
  			all 
  		end
  	end
  #FILTROS DE BUSQUEDA

  #FUNCIONES
  	def self.last_value company_id
  		daily_cashes = where(company_id: company_id)
  		if daily_cashes.empty?
  			0.0
  		else
  			daily_cashes.order("created_at DESC").last.final_amount
  		end
  	end

    def self.current_daily_cash
      daily = where(date: Date.today).first
      if daily.nil?
        raise Exceptions::DailyCashClose
      else
        return daily
      end
    end
  #FUNCIONES

  #PROCESOS
    def create_initial_movement
      self.daily_cash_movements.create(
        movement_type: "Apertura de caja",
        amount: initial_amount,
        associated_document: "-",
        payment_type: "",
        flow: "income"
      )
    end
  #PROCESOS
end
