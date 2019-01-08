class CreateBudgetDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :budget_details do |t|
      t.float :price_per_unit, null: false, default: 0.0
      t.string :product_name, null: false
      t.string :measurement_unit, null: false
      t.float :quantity, null: false, default: 0.0
      t.float :bonus_percentage, null: false, default: 0.0
      t.float :bonus_amount, null: false, default: 0.0
      t.float :subtotal, null: false, default: 0.0
      t.boolean :active, null: false, default: true
      t.references :product, foreign_key: true
      t.references :depot, foreign_key: true
      t.references :budget, foreign_key: true

      t.timestamps
    end
  end
end
