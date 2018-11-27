class CreateDepots < ActiveRecord::Migration[5.2]
  def change
    create_table :depots do |t|
      t.string :name
      t.boolean :active, null: false, default: true
      t.references :company, foreign_key: true
      t.float :stock_count, null: false, default: 0.0
      t.boolean :filled, null: false, default: false
      t.string :location, null: false

      t.timestamps
    end
  end
end
