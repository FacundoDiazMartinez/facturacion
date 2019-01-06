class CreateBanks < ActiveRecord::Migration[5.2]
  def change
    create_table :banks do |t|
      t.string :name, null: false
      t.string :cbu, null: false
      t.string :account_number
      t.references :company, foreign_key: true
      t.float :current_amount, null: false, default: 0

      t.timestamps
    end
  end
end
