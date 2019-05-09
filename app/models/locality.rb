class Locality < ApplicationRecord
  belongs_to :province
  has_many :users
	has_many :companies

  default_scope { where(active: true ) }

  def destroy
  	update_column(:active, false)
  	run_callbacks :destroy
  end
end
