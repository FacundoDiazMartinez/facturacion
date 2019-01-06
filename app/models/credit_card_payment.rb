class CreditCardPayment < ApplicationRecord
  belongs_to :payment
  belongs_to :credit_card
end
