class AccountMovementPayment < Payment
	belongs_to :account_movement
	belongs_to :invoice, optional: true

	before_validation :set_flow, :set_total_to_receipt
	after_destroy :set_total_pay_to_invoice
	after_destroy :update_total_to_receipt
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

		def update_total_to_receipt
			receipt = self.account_movement.receipt
			receipt.update_column(:total, receipt.total - total)
		end

		def check_company_id
 			self.company_id = self.account_movement.receipt.company_id unless self.account_movement.receipt.nil?
 		end

 		def check_client_id
 			self.client_id = self.account_movement.client_id
 		end

    def set_flow
 			self.flow = self.account_movement.cbte_tipo == "99" ? "expense" : "income"
 		end

 		def set_total_pay_to_invoice
			unless invoice_id.nil?
				sum = invoice.sum_payments
	  		invoice.update_column(:total_pay, sum) unless sum == invoice.total_pay
			end
  	end

		def account_movement
			AccountMovement.unscoped { super }
		end

		def destroy(mode = :soft)
		    if mode == :hard
		      	super()
		    else
			    self.update_column(:active, false)
					pp "REMIL ENTRO"
					p = self
			    self.run_callbacks :destroy
					self.set_total_pay_to_invoice
					self.update_total_to_receipt
			    self.freeze
		    end
		end
	#PRECESOS
end
