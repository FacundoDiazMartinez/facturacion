class ChequePayment < ApplicationRecord
	include Subpayment
  	belongs_to :payment

  	STATES = ["Cobrado", "No cobrado"]

  	ORIGINS =["Propio", "De tercero"] 
end
