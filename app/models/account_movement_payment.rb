class AccountMovementPayment < Payment
	belongs_to :account_movement, touch: true
	belongs_to :invoice, optional: true

	before_validation :set_flow
	after_destroy :set_total_pay_to_invoice, if: Proc.new{|amp| !amp.invoice_id.nil?}

	validates_numericality_of :total, greater_than_or_equal_to: 0.0, message: "El monto pagado debe ser mayor o igual a 0."

	self.table_name = "payments"

	def self.default_scope
    	where(active: true)
 	end

 	#ATRIBUTOS
 	#ATRIBUTOS

	#PROCESOS
    	def set_flow
 			self.flow = "income"
 		end

 		def set_total_pay_to_invoice
			sum = invoice.sum_payments
	  		invoice.update_column(:total_pay, sum) unless sum == invoice.total_pay
	  	end
	#PRECESOS
end