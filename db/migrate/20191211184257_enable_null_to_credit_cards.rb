class EnableNullToCreditCards < ActiveRecord::Migration[5.2]
  def change
    change_column :fees, :coefficient, :float, default: 0.0
  end
end
