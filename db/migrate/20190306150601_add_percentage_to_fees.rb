class AddPercentageToFees < ActiveRecord::Migration[5.2]
  def change
    add_column :fees, :percentage, :float, default: 0
  end
end
