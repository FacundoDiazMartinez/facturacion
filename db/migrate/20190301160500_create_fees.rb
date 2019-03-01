class CreateFees < ActiveRecord::Migration[5.2]
  def change
    create_table :fees do |t|
      t.references :credit_card, foreign_key: true
      t.integer :quantity, null: false
      t.float :coefficient, null: false
      t.float :tna
      t.float :tem
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end
