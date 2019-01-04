class IncomePayment < Payment
	belongs_to :invoice
	after_save :set_total_pay_to_invoice
	after_save :set_notification
	before_validation :set_flow

	validates_numericality_of :total, greater_than_or_equal_to: 0.0, message: "El monto pagado debe ser mayor o igual a 0."

	self.table_name = "payments"

	def self.default_scope
    	where(flow: "income")
 	end

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
	#PRECESOS
end