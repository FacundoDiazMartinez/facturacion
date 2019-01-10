class ChangeNumberFromDeliveryNotes < ActiveRecord::Migration[5.2]
  def change
  	change_column :delivery_notes, :number, :string, null: false
  end
end
