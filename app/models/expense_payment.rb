class ExpensePayment < Payment
	belongs_to :purchase_order

	self.table_name = "payments"

	before_validation :set_flow

	def self.default_scope
    	where(flow: "expense", active: true)
 	end

 	def set_flow
 		self.flow = "expense"
 	end

end