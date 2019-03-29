class ExpensePayment < Payment
	belongs_to :purchase_order, touch: true

	self.table_name = "payments"

	before_validation :set_flow
	before_save :check_company_id

	def self.default_scope
    	where(flow: "expense", active: true)
 	end

 	def set_flow
 		self.flow = "expense"
 	end

	def check_company_id
		self.company_id = purchase_order.company_id
	end

end
