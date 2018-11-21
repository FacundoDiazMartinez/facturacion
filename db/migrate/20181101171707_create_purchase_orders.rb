class CreatePurchaseOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :purchase_orders do |t|
      t.integer :number, null: false
      t.string :state, null: false, default: "Pendiente de aprobación"
      t.references :supplier, foreign_key: true
      t.string :number, null: false
      t.text :observation
      t.float :total, null: false, default: 0.0
      t.float :total_pay, null: false, default: 0.0
      t.references :user, foreign_key: true
      t.boolean :shipping, null: false, default: false
      t.float :shipping_cost, null: false, default:false
      t.references :company, foreign_key: true
      t.references :budget

      t.timestamps
    end
  end
end
