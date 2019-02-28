class IncomePayment < Payment
	self.table_name = "payments"

	belongs_to :invoice
	belongs_to :account_movement, optional: true

	after_save :set_total_pay_to_invoice
	after_save :set_notification
	after_save :touch_invoice, unless: :generated_by_system
	after_destroy :set_amount_available_to_account_movement
	before_save :change_credit_card_balance, if: Proc.new{|ip| ip.type_of_payment == "1" && ip.total_changed?}
	before_save :check_company_id
	before_save :check_client_id
	before_validation :set_flow

	validate :check_max_total, if: Proc.new{|ip| !ip.invoice_id.blank? }
	validate :check_available_saldo, if: Proc.new{|ip| ip.type_of_payment == "6"}

	def self.default_scope
    	where(flow: "income", active: true)
 	end

 	#VALIDACIONES
 		def check_max_total
 			errors.add(:total, "No se puede generar pagos por un total mayor que el de la factura. Si desea generar saldo a favor puede hacerlo desde la cuenta corriente.") unless (invoice.sum_payments - total_was.to_f + total.to_f) <= invoice.total
 		end

 		def check_available_saldo
 			errors.add(:total, "No posee el saldo suficiente en su cuenta corriente.") unless total.to_f <= invoice.client.account_movements.sum(:amount_available)
 		end

 		def check_company_id
 			self.company_id = invoice.company_id
 		end

 		def check_client_id
 			self.client_id = invoice.client_id
 		end
 	#VALIDACIONES

 	#ATRIBUTOS
 		def credit_card_id=(credit_card_id)
 			@credit_card_id = credit_card_id
 		end

 		def credit_card_id
 			@credit_card_id
 		end
 	#ATRIBUTOS

	#PROCESOS
		def set_amount_available_to_account_movement
			unless self.account_movement.nil?
				self.account_movement.update_column(:amount_available, self.account_movement.amount_available.to_f + self.total.to_f)
			end
		end

		def touch_invoice
			pp "TOUCH INVOICE"
			invoice.touch
		end

		def destroy
	      	update_column(:active, false)
	      	set_total_pay_to_invoice
	      	run_callbacks :destroy
	      	freeze
	    end

		def set_total_pay_to_invoice
			sum = invoice.sum_payments
  		invoice.update_column(:total_pay, sum) #unless sum == invoice.total_pay
  	end

  	def set_notification
     	Notification.create_from_payment(self)
    end

  	def set_flow
			self.flow = "income"
 		end

 		def change_credit_card_balance
 			CreditCard.find(@credit_card_id).update_balance_from_payment(self)
 		end
	#PRECESOS
end
