class CreateStocks < ActiveRecord::Migration[5.2]
  def change
    create_table :stocks do |t|
      t.references :product, foreign_key: true
      t.string :state
      t.float :quantity

      t.timestamps
    end
  end
end
