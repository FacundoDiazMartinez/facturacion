class DebitPayment < ApplicationRecord
  include Subpayment
    belongs_to :bank
    belongs_to :payment

    default_scope { where(active: true ) }


    def destroy
  		update_column(:active, false)
  		run_callbacks :destroy
  	end
end
