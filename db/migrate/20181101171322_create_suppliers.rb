class CreateSuppliers < ActiveRecord::Migration[5.2]
  def change
    create_table :suppliers do |t|
      t.string :name, null: false
      t.string :document_type
      t.string :document_number
      t.string :phone
      t.string :mobile_phone
      t.string :address
      t.string :email
      t.string :cbu
      t.boolean :active, null: false, default: true
      t.references :company, foreign_key: true

      t.timestamps
    end
  end
end
