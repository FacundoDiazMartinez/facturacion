class AddMeasurementToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :measurement, :string
  end
end
