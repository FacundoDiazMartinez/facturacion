class AccountMovementPayment < Payment
	belongs_to :account_movement
	belongs_to :invoice, optional: true

	before_validation :set_flow, :set_total_to_receipt
	after_destroy :set_total_pay_to_invoice, if: Proc.new{|amp| !amp.invoice_id.nil?}
	after_destroy :reduce_total_to_receipt
	before_save :check_company_id
	before_save :check_client_id
	before_validation :check_total_from_account_movement

	validates_numericality_of :total, greater_than_or_equal_to: 0.0, message: "El monto pagado debe ser mayor o igual a 0."

	self.table_name = "payments"

	def self.default_scope
    	where(active: true)
 	end

 	#ATRIBUTOS

 	#ATRIBUTOS

	#PROCESOS
		def check_total_from_account_movement
			#self.total = self.account_movement.total
		end

		def set_total_to_receipt
			self.account_movement.receipt.total += total - total_was
		end

		def reduce_total_to_receipt
			self.account_movement.receipt.update_column(:total, total)
		end

		def check_company_id
 			self.company_id = self.account_movement.receipt.company_id unless self.account_movement.receipt.nil?
 		end

 		def check_client_id
 			self.client_id = self.account_movement.client_id
 		end

    	def set_flow
 			self.flow = "income"
 		end

 		def set_total_pay_to_invoice
			sum = invoice.sum_payments
	  		invoice.update_column(:total_pay, sum) unless sum == invoice.total_pay
	  	end
	#PRECESOS
end
