class AccountMovementPayment < Payment
	self.table_name = "payments"
	## 2 tipos de pagos:
	## registrados por el usuario: pagos que hizo el Cliente
	## registrados por el sistema: pagos utilizados para pagar comprobantes
	belongs_to :account_movement, touch: true ##al guardar o eliminar ejecuta un touch
	belongs_to :invoice, optional: true
	belongs_to :receipt, optional: true

	before_validation :set_flow
	before_validation :check_receipt_state ## evita borrar pagos de un recibo confirmado

	before_save 			:check_company_id
	before_save 			:check_client_id
	after_destroy 		:set_total_pay_to_invoice

	def confirmar!
		if account_movement.receipt
			self.save_daily_cash_movement ## perteneciente al modelo de Payment
		end
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
	    account_movement.touch
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
