class Fee < ApplicationRecord
  belongs_to :credit_card

  default_scope { where(active: true) }

  def destroy
    update_column(:active, false)
  end
end
