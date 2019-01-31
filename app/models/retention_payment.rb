class RetentionPayment < ApplicationRecord
	include Subpayment
  	belongs_to :payment
end
