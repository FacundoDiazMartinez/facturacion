class CompensationPayment < ApplicationRecord
  include Subpayment
  	belongs_to :payment
    belongs_to :client, optional: true

    validates_presence_of :client_id, message: "El pago por compensación debe estar asociado a un cliente."

    default_scope { where(active: true ) }

    def destroy
  		update_column(:active, false)
  		run_callbacks :destroy
  	end
end
