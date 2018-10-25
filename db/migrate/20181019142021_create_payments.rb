class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.string :type_of_payment
      t.float :total
      t.references :invoice, foreign_key: true

      t.timestamps
    end
  end
end
