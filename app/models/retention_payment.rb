class RetentionPayment < ApplicationRecord
	include Subpayment
	belongs_to :payment
	validates_numericality_of :number, message: "Sólo se permite ingresar números, para el campo numeración de la retención."

	default_scope { where(active: true ) }

	

	def destroy
		update_column(:active, false)
		run_callbacks :destroy
	end
end
