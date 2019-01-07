class IncomePayment < Payment
	belongs_to :invoice, touch: true
	after_save :set_total_pay_to_invoice
	after_save :set_notification
	before_save :change_credit_card_balance, if: Proc.new{|ip| ip.type_of_payment == "1" && ip.total_changed?}
	before_validation :set_flow

	validates_numericality_of :total, greater_than_or_equal_to: 0.0, message: "El monto pagado debe ser mayor o igual a 0."

	self.table_name = "payments"

	def self.default_scope
    	where(flow: "income", active: true)
 	end

 	#ATRIBUTOS
 		def credit_card_id=(credit_card_id)
 			@card_id = credit_card_id
 		end

 		def credit_card_id
 		end
 	#ATRIBUTOS

	#PROCESOS
		def set_total_pay_to_invoice
	  		invoice.update_column(:total_pay, invoice.sum_payments)
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
