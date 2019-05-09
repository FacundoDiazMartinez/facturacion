class Permission < ApplicationRecord
  belongs_to :friendly_name
  has_many :role_permissions

  default_scope { where(active: true ) }

  def subject_class
  	self.friendly_name.subject_class
  end

  def destroy
  	update_column(:active, false)
  	run_callbacks :destroy
  end
end
