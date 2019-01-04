class FixUserToDailyCashes < ActiveRecord::Migration[5.2]
  def change
  	add_reference :daily_cash_movements, :user, foreign_key: true
  	remove_column :daily_cashes, :user_id
  end
end
