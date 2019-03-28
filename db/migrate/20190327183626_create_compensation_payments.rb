class CreateCompensationPayments < ActiveRecord::Migration[5.2]
  def change
    create_table :compensation_payments do |t|
      t.float :total
      t.references :payment
      t.boolean :active
      t.string :asociatedClientInvoice
      t.text :observation
      t.string :concept
      t.references :client, foreign_key: true

      t.timestamps
    end
  end
end
