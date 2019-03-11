class DebitPayment < ApplicationRecord
  include Subpayment
    belongs_to :bank
    belongs_to :payment
end
