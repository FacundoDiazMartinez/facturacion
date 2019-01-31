class CardPayment < ApplicationRecord
	include Subpayment
  	belongs_to :payment
  	belongs_to :credit_card

end
