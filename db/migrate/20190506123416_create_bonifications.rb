class CreateBonifications < ActiveRecord::Migration[5.2]
  def change
    create_table :bonifications do |t|
      t.float :subtotal, null: false
      t.string :observation
      t.float :percentage, null: false, default: 0.0
      t.float :amount, null: false, default: 0.0
      t.references :invoice, foreign_key: true

      t.timestamps
    end
  end
end
