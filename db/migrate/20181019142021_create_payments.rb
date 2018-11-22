class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.string :type_of_payment
      t.float :total, null: false, default: 0.0
      t.boolean :active, null: false, default: true
      t.references :invoice, foreign_key: true
      t.bigint :delayed_job_id
      t.date :payment_date, null: false, default: -> { 'CURRENT_DATE' }

      t.timestamps
    end
  end
end
