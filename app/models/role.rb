class Role < ApplicationRecord
  belongs_to :company
  
  has_many   :role_permissions
  has_many   :permissions, through: :role_permissions
end
