class Permission < ApplicationRecord
  belongs_to :friendly_name
  has_many :role_permissions

  def subject_class
  	self.friendly_name.subject_class
  end
end
