class DelayedJob < ApplicationRecord
	belongs_to :payment, optional: true
end