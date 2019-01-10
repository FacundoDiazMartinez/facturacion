class DeliveryNote < ApplicationRecord
  belongs_to :company
  belongs_to :invoice
  belongs_to :user
  belongs_to :client
  has_many :delivery_note_details, dependent: :destroy

  accepts_nested_attributes_for :arrival_note_details, reject_if: :all_blank, allow_destroy: true

  before_validation :set_number


  #PROCESOS
    def set_number
      self.number = self.number.to_s.rjust(8,padstr= '0')
    end

    def destroy
      update_column(:active, false)
      run_callbacks :destroy
      freeze
    end
  #PROCESOS


end
