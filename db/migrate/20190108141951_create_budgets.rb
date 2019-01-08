class CreateBudgets < ActiveRecord::Migration[5.2]
  def change
    create_table :budgets do |t|
      t.date :date, null: false, default: -> { 'CURRENT_DATE' }
      t.string :state, null: false, default: "Pendiente"
      t.date :expiration_date
      t.string :number, null: false
      t.float :total, null: false, default: 0.0
      t.boolean :active, null: false, default: true
      t.references :company, foreign_key: true
      t.references :user, foreign_key: true
      t.references :client, foreign_key: true
      t.boolean :reserv_stock, null: false, default: false

      t.timestamps
    end
  end
end
