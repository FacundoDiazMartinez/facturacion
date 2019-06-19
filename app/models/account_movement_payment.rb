class AccountMovementPayment < Payment
	self.table_name = "payments"
	belongs_to :account_movement
	belongs_to :invoice, optional: true

	before_validation :set_flow
	before_validation :check_receipt_state

	before_save 			:check_company_id
	before_save 			:check_client_id
	after_save 				:update_total_to_receipt
	after_destroy 		:update_total_to_receipt
	after_destroy 		:set_total_pay_to_invoice

	## sólo para pagos que pertenecen a un recibo
	## suma todos los pagos (activos) en el recibo y actualiza su TOTAL
	def update_total_to_receipt
		self.account_movement.receipt.save unless self.account_movement.receipt.nil?
		self.account_movement.set_amount_available unless self.account_movement.nil?
		self.account_movement.receipt.save_amount_available unless self.account_movement.receipt.nil?
	end

	def set_total_pay_to_invoice
		unless self.invoice_id.nil?
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
	    update_column(:active, false)
	    update_total_to_receipt
			set_total_pay_to_invoice
	    freeze
    end
	end
	#PRECESOS
	private
	def check_company_id
		self.company_id = self.account_movement.receipt.company_id unless self.account_movement.receipt.nil?
	end

	def check_client_id
		self.client_id = self.account_movement.client_id
	end

	def set_flow
		self.flow = self.account_movement.cbte_tipo == "99" ? "expense" : "income"
	end

	def check_receipt_state
	  unless account_movement.receipt.nil?
			errors.add("Recibo confirmado", "Los pagos de un recibo confirmado no pueden ser modificados.") unless account_movement.receipt.editable?
	  end
	end
end
