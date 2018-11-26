class Province < ApplicationRecord
	has_many :users
	has_many :companies
	has_many :localities
	
end
