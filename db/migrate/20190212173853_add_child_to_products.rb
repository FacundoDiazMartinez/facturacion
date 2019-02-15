class AddChildToProducts < ActiveRecord::Migration[5.2]
  def change
    add_reference :products, :product, foreign_key: true
  end
end
