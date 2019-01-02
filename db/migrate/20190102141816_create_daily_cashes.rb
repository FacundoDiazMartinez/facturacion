class CreateDailyCashes < ActiveRecord::Migration[5.2]
  def change
    create_table :daily_cashes do |t|
      t.references :company, foreign_key: true
      t.string :state
      t.float :initial_amount, null: false, default: 0.0
      t.float :final_amount, null: false, default: 0.0
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
