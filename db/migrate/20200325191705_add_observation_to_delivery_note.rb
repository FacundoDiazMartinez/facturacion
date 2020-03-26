class AddObservationToDeliveryNote < ActiveRecord::Migration[5.2]
  def change
    add_column :delivery_notes, :observation, :text
  end
end
