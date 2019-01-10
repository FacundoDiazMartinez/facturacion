class AddDefaultToProducts < ActiveRecord::Migration[5.2]
  def change
  	remove_column :products, :measurement_unit, :string
  	add_column :products, :measurement_unit, :string, default: "7", null: false
  end
end
