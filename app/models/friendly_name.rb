class FriendlyName < ApplicationRecord
  has_many :permissions, dependent: :destroy
end