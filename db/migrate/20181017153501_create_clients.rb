class CreateClients < ActiveRecord::Migration[5.2]
  def change
    create_table :clients do |t|
      t.string :name, null: false
      t.string :phone
      t.string :mobile_phone
      t.string :email
      t.string :address
      t.string :document_type, null: false, default: "D.N.I."
      t.string :document_number, null: false
      t.string :birthday
      t.boolean :active, null: false, default: true
      t.string :iva_cond, null: false, default: "Responsable Monotributo"
      t.references :company, foreign_key: true

      t.timestamps
    end
  end
end
