class BankPayment < ApplicationRecord
	include Subpayment
  	belongs_to :bank
  	belongs_to :payment

		after_save :update_bank_balance

		default_scope { where(active: true) }

		def self.search_by_bank bank
		    if !bank.blank?
		      where("banks.name = ?", bank)
		    else
		      all
		    end
		end

		def update_bank_balance
			pp payment
			self.bank.update_balance_from_payment(self.payment)
		end
end
