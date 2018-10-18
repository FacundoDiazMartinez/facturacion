class Locality < ApplicationRecord
  belongs_to :province
  has_many :users
	has_many :companies
end
