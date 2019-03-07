class AddFavLogoToCreditCards < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_cards, :fav_logo, :string, default: "credit-card", null: false
  end
end
