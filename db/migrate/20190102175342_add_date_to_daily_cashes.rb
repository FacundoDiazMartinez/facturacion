class AddDateToDailyCashes < ActiveRecord::Migration[5.2]
  def change
    add_column :daily_cashes, :date, :date, null: false
  end
end
