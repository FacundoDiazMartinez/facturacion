class CreateCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :companies do |t|
      t.string :email, null: false
      t.string :code, null: false, uniq: true
      t.string :name, null: false, uniq: true
      t.string :logo
      t.string :address
      t.string :society_name
      t.string :cuit, null: false, uniq: true
      t.string :concepto, null: false
      t.string :moneda, null: false, default: 'PES'
      t.string :iva_cond, null: false
      t.string :country, null: false, default: 'Argentina'
      t.string :city
      t.string :location
      t.string :postal_code
      t.date :activity_init_date
      t.string :contact_number
      t.string :environment, null: false, default: 'testing'
      t.string :cbu
      t.boolean :paid, null: false, default: false
      t.string :suscription_type

      t.timestamps
    end
  end
end
