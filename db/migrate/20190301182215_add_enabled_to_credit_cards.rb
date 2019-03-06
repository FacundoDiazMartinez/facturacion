class AddEnabledToCreditCards < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_cards, :enabled, :boolean, default: true, null: false
  end
end
