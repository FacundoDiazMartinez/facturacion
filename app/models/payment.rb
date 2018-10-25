class Payment < ApplicationRecord
  belongs_to :invoice

  after_save :set_total_pay_to_invoice

  TYPES = {
  	0 => "Contado",
  	1 => "Tarjeta de crédito",
  	2 => "Tarjeta de débito",
  	3 => "Transferencia bancaria",
  	4 => "Cheque",
  	5 => "Retenciones"
  }

  #ATRIBUTOS
  	def set_total_pay_to_invoice
  		invoice.update_attribute(:total_pay, invoice.sum_payments)
  	end
  #ATRIBUTOS
end
