class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :role

  has_many   :permissions, through: :role

  #validate :already_has_role, on: :create

  validates_uniqueness_of :role_id, scope: :user_id, message: 'El empleado ya tiene asignado el rol que intenta darle'

end
