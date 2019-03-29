class Bank < ApplicationRecord
  belongs_to :company
  has_many :bank_payments

  def update_balance_from_payment payment
    new_total =  payment.saved_change_to_total
  	payment_total = new_total.last - new_total.first
  	update_column(:current_amount, current_amount + payment_total)
  end

end
