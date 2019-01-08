class DeliveryNote < ApplicationRecord
  belongs_to :company
  belongs_to :invoice
  belongs_to :user
  belongs_to :client
  has_many :delivery_note_details, dependent: :destroy

  def destroy
    update_column(:active, false)
    run_callbacks :destroy
    freeze
  end

end
