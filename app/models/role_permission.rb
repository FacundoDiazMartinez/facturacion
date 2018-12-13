class RolePermission < ApplicationRecord
  belongs_to :role
  belongs_to :permission

  validates_uniqueness_of :role_id, scope: :permission_id

  def permission_description_autocomplete
    self.permission.blank? ? '' : "#{self.permission.description}"
  end

  def self.generate_new_role_permission role, permission
    rp = RolePermission.new(
      role_id: role.id,
      permission_id: permission.id
    )

    if rp.save
      return true
    else
      return false
    end
  end
  
end
