class AddTypeOfFeeToCreditCards < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_cards, :type_of_fee, :string, null: false, default: "Porcentaje"
  end
end
