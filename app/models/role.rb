class Role < ApplicationRecord
  belongs_to :company

  has_many   :role_permissions
  has_many   :permissions, through: :role_permissions
  has_many   :user_roles
  has_many   :users, through: :user_roles

  default_scope { where(active: true ) }

  def destroy
		update_column(:active, false)
		run_callbacks :destroy
	end
end
