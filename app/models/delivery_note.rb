class DeliveryNote < ApplicationRecord
  belongs_to :company
  belongs_to :invoice
  belongs_to :user
  belongs_to :client
end
