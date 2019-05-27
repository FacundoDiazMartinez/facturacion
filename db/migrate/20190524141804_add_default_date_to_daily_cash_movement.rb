class AddDefaultDateToDailyCashMovement < ActiveRecord::Migration[5.2]
  	def down
  		change_column :daily_cash_movements, :date, :date
  	end
  	def up
  		change_column :daily_cash_movements, :date, :datetime
  	end
end
