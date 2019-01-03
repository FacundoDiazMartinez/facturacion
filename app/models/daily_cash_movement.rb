class DailyCashMovement < ApplicationRecord
  belongs_to :daily_cash
  belongs_to :payment, optional: true

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
  #ATRIBUTOS

  #PROCESOS
  	def self.save_from_payment payment
  		movement = where(daily_cash_id: DailyCash.current_daily_cash.id, payment_id: payment.id).first_or_initialize
  		movement.movement_type 			  =  "Pago"
  		movement.amount 				      =  payment.total
  		movement.associated_document 	=  payment.associated_document
  		movement.payment_type			    =  payment.type_of_payment
  		movement.flow 					      =  payment.flow
  		movement.payment_id 			    =  payment.id
  		movement.save
  	end
  #PROCESOS
end
