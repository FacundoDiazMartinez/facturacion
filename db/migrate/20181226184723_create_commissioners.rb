class CreateCommissioners < ActiveRecord::Migration[5.2]
  def change
    create_table :commissioners do |t|
      t.references :user, foreign_key: true
      t.references :invoice_detail, foreign_key: true
      t.float :percentage, null:false, default: 0.0
      t.boolean :active, null: false, default: false
      t.float :total_commission, null: false
      t.timestamps
    end
  end
end
