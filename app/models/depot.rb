class Depot < ApplicationRecord
  belongs_to :company
  has_many   :stocks
end
