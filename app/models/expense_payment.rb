class ExpensePayment < Payment
	belongs_to :purchase_order, touch: true

	self.table_name = "payments"

	before_validation :set_flow
	before_save :check_company_id
	before_destroy :touch_purchase_order

	def self.default_scope
    	where(flow: "expense", active: true)
 	end

 	def set_flow
 		self.flow = "expense"
 	end

	def check_company_id
		self.company_id = purchase_order.company_id
	end

	def touch_purchase_order
		self.purchase_order.set_total_pay
	end

end
