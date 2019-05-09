class Province < ApplicationRecord
	has_many :users
	has_many :companies
	has_many :localities

	default_scope { where(active: true ) }

	def destroy
		update_column(:active, false)
		run_callbacks :destroy
	end

end
