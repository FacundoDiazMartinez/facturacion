class CreatePriceChanges < ActiveRecord::Migration[5.2]
  def change
    create_table :price_changes do |t|
      t.string :name, null: false
      t.references :company, index: true, foreign_key: true
      t.references :supplier, index: true, foreign_key: true
      t.references :product_category, index: true, foreign_key: true
      t.references :creator, index: true, foreign_key: { to_table: :users }
      t.references :applicator, index: true, foreign_key: { to_table: :users }
      t.datetime :application_date
      t.decimal :modification, null: false
      t.boolean :applied, default: false, null: false

      t.timestamps
    end
  end
end
