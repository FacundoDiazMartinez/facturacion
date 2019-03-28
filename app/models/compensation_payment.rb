class CompensationPayment < ApplicationRecord
  include Subpayment
  	belongs_to :payment
    belongs_to :client
end
