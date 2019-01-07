class ExpensePayment < Payment
	belongs_to :purchase_order
	after_save :set_purchase_order_paid_out

	self.table_name = "payments"

	before_validation :set_flow

	def set_purchase_order_paid_out
		if purchase_order.total.to_f - purchase_order.payments.sum(:total).to_f == 0
			purchase_order.update_column(:paid_out, true)
		end
	end

	def self.default_scope
    	where(flow: "expense", active: true)
 	end

 	def set_flow
 		self.flow = "expense"
 	end

end
