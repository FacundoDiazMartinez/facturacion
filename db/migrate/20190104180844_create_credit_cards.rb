class CreateCreditCards < ActiveRecord::Migration[5.2]
  def change
    create_table :credit_cards do |t|
      t.string :name, null: false
      t.references :company, foreign_key: true
      t.float :current_amount, null: false, default: 0

      t.timestamps
    end
  end
end
