class IncomePayment < Payment
	self.table_name = "payments"

	belongs_to :invoice
	belongs_to :account_movement, optional: true, touch: true ##IMPORTANTE debe actualizar los montos del movimiento de cuenta

	before_save 	:check_company_id
	after_destroy 	:set_amount_available_to_account_movement

	validate 		:check_max_total, if: Proc.new{|ip| !ip.invoice.nil? && ip.account_movement.try(:receipt_id).nil?}
	validate 		:check_available_saldo, if: Proc.new{|ip| ip.type_of_payment == "6"}

 	#VALIDACIONES
 		def check_max_total
			if payments_greater_than_invoice_total?
				unless type_of_payment == "1" && (invoice.sum_payments + card_payment.subtotal.to_f <= invoice.total)
 					errors.add(:total, "No se puede generar pagos por un total mayor que el de la factura. Si desea generar saldo a favor puede hacerlo desde la cuenta corriente.")
				end
			end
 		end

 		def check_available_saldo
 			errors.add(:total, "No posee el saldo suficiente en su cuenta corriente.") unless (total.to_f <= invoice.client.account_movements.where('account_movements.amount_available > 0').sum(:amount_available).to_f || invoice.is_credit_note?)
 		end

 		def check_company_id
 			self.company_id = self.invoice.company_id
			self.client_id 	= self.invoice.client_id
 		end
 	#VALIDACIONES

 	#ATRIBUTOS
	def credit_card_id
		@credit_card_id
	end

	def card_payment_attributes=(attributes)
		@credit_card_id = attributes[:credit_card_id]
		super
	end
 	#ATRIBUTOS

	#PROCESOS
	def payment_name_with_receipt
		if type_of_payment == "06"
			"Cuenta Corriente - RX:  #{self.account_movement.receipt.number}"
		end
	end

	def set_amount_available_to_account_movement
		unless self.account_movement.nil?
			self.account_movement.update_column(:amount_available, self.account_movement.amount_available.to_f + self.total.to_f)
		end
	end

	def destroy
  	update_column(:active, false)
  	set_total_pay_to_invoice
  	run_callbacks :destroy
  	freeze
  end

	def set_total_pay_to_invoice
		sum = invoice.sum_payments
		invoice.update_column(:total_pay, sum)
	end
	#PROCESOS

	private
	default_scope { where(flow: "income") }

	def payments_greater_than_invoice_total?
		resultado = invoice.sum_payments - self.total_was.to_f + self.total.to_f
		resultado.round(2) > invoice.total
	end

end
