class DailyCashMovement < ApplicationRecord
  belongs_to :daily_cash
  belongs_to :user, optional: true
  belongs_to :payment, optional: true

  after_initialize :set_daily_cash
  after_save :touch_daily_cash_current_amount

  before_validation :set_payment_type

  TYPES = ["Pago", "Ajuste"]

  FLOW_TYPES = {
    "Egreso"    => "expense",
    "Ingreso"   => "income"
   }

  #FILTROS DE BUSQUEDA
    def self.search_by_user user
      if !user.blank?
        where(user_id: user)
      else
        all 
      end
    end

    def self.search_by_payment_type payment_type
      if !payment_type.nil?
        where(payment_type: payment_type)
      else
        all 
      end
    end
  #FILTROS DE BUSQUEDA

  #ATRIBUTOS
  	def flow_type
  		case flow
  		when "income"
  			"Ingreso"
  		when "expense"
  			"Egreso"
  		else
  			"-"
  		end
  	end

    def user_name
      user.nil? ? "Generado por sistema" : user.name
    end

    def user_avatar
      user.nil? ? "/images/default_user.png" : user.avatar
    end
  #ATRIBUTOS

  #PROCESOS
  	def self.save_from_payment payment, company_id
  		movement = where(daily_cash_id: DailyCash.current_daily_cash(company_id).id, payment_id: payment.id).first_or_initialize
  		movement.movement_type 			   =  "Pago"
  		movement.amount 				       =  payment.total
  		movement.associated_document 	 =  payment.associated_document
  		movement.payment_type			     =  payment.type_of_payment
  		movement.flow 					       =  payment.flow
  		movement.payment_id 			     =  payment.id
      movement.user_id               =  payment.user_id
  		movement.save
  	end

    def touch_daily_cash_current_amount
      daily_cash.update_current_amount
    end

    def set_daily_cash
      self.daily_cash_id ||= DailyCash.current_daily_cash(User.find(self.user_id).company_id).id
    end

    def set_payment_type
       self.payment_type ||= "0"
    end 
  #PROCESOS
end
