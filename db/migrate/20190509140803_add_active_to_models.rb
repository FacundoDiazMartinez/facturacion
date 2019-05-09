class AddActiveToModels < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_cards, :active, :boolean, null: false, default: true
    add_column :daily_cashes, :active, :boolean, null: false, default: true
    add_column :friendly_names, :active, :boolean, null: false, default: true
    add_column :localities, :active, :boolean, null: false, default: true
    add_column :permissions, :active, :boolean, null: false, default: true
    add_column :provinces, :active, :boolean, null: false, default: true
    add_column :roles, :active, :boolean, null: false, default: true
    add_column :sale_points, :active, :boolean, null: false, default: true
    add_column :sales_files, :active, :boolean, null: false, default: true
    add_column :user_roles, :active, :boolean, null: false, default: true
    change_column :invoices, :active, :boolean, null: false, default: true
    change_column :products, :active, :boolean, null: false, default: true
  end
end
