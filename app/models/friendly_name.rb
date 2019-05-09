class FriendlyName < ApplicationRecord
  has_many :permissions, dependent: :destroy
  default_scope { where(active: true ) }


  def destroy
  	update_column(:active, false)
  	run_callbacks :destroy
  end
  
end
