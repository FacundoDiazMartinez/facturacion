class Client < ApplicationRecord
	has_many :invoices
	belongs_to :company
end
