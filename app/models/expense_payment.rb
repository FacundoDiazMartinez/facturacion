class ExpensePayment < Payment
	self.table_name = "payments"
	belongs_to :purchase_order, touch: true

	before_save :check_company_id
	before_destroy :touch_purchase_order

	def check_company_id
		self.company_id = purchase_order.company_id
	end

	def touch_purchase_order
		self.purchase_order.set_total_pay
	end

	def destroy
		update_column(:active, false)
		run_callbacks :destroy
	end

	private
	default_scope { where(flow: "expense") }
end
