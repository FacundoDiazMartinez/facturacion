class AddActiveToModels2 < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :active, :boolean, null: false, default: true
    add_column :daily_cash_movements, :active, :boolean, null: false, default: true
    add_column :daily_cash_movements, :updated_by, :bigint
  end
end
