class CashPayment < ApplicationRecord
	include Subpayment
  belongs_to :payment
end
