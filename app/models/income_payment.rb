class IncomePayment < Payment
	belongs_to :invoice
	after_save :set_total_pay_to_invoice
	after_save :set_notification
	before_validation :set_flow

	self.table_name = "payments"

	def self.default_scope
    	where(flow: "income")
 	end

	#PROCESOS
		def set_total_pay_to_invoice
  		invoice.update_attribute(:total_pay, invoice.sum_payments)
  	end

  	def set_notification
     	Notification.create_from_payment(self)
    end

    def set_flow
 			self.flow = "income"
 		end
	#PRECESOS
end
