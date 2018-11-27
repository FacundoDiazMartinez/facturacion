class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :role

  has_many   :permissions, through: :role
end
