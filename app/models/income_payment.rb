class IncomePayment < Payment
	self.table_name = "payments"

	belongs_to :invoice
	belongs_to :account_movement, optional: true

	after_save :set_total_pay_to_invoice
	after_save :set_notification
	after_save :touch_invoice, if: Proc.new{ |ip| !ip.generated_by_system }
	before_save :change_credit_card_balance, if: Proc.new{|ip| ip.type_of_payment == "1" && ip.total_changed?}
	before_validation :set_flow

	validates_numericality_of :total, greater_than_or_equal_to: 0.0, message: "El monto pagado debe ser mayor o igual a 0."
	validate :check_max_total
	validate :check_available_saldo, if: Proc.new{|ip| ip.type_of_payment == "6"}

	

	def self.default_scope
    	where(flow: "income", active: true)
 	end

 	#VALIDACIONES
 		def check_max_total
 			errors.add(:total, "No se puede generar pagos por un total mayor que el de la factura. Si desea generar saldo a favor puede hacerlo desde la cuenta corriente.") unless (invoice.sum_payments - total_was + total) <= invoice.total
 		end

 		def check_available_saldo
 			errors.add(:total, "No posee el saldo suficiente en su cuenta corriente.") unless total.to_f <= -invoice.client.saldo.to_f
 		end
 	#VALIDACIONES

 	#ATRIBUTOS
 		def credit_card_id=(credit_card_id)
 			@card_id = credit_card_id
 		end

 		def credit_card_id
 		end
 	#ATRIBUTOS

	#PROCESOS
		def touch_invoice
			invoice.touch
		end
		
		def set_total_pay_to_invoice
			sum = invoice.sum_payments
	  		invoice.update_column(:total_pay, sum) unless sum == invoice.total_pay
	  	end

	  	def set_notification
	     	Notification.create_from_payment(self)
	    end

    	def set_flow
 			self.flow = "income"
 		end

 		def change_credit_card_balance
 			CreditCard.find(@card_id).update_balance_from_payment(self)
 		end
	#PRECESOS
end
