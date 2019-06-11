class AddActiveToStocks < ActiveRecord::Migration[5.2]
  def change
    add_column :stocks, :active, :boolean, default:true, null:false
  end
end
