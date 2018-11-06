class ArrivalNote < ApplicationRecord
  belongs_to :company
  belongs_to :purchase_order
  belongs_to :user
end
