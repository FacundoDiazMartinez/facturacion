class CreateInvoiceDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :invoice_details do |t|
      t.references :invoice, foreign_key: true
      t.references :product, foreign_key: true
      t.float :quantity, null:false, default: 1
      t.string :measurement_unit, null: false
      t.float :price_per_unit, null: false, default: 0.0
      t.float :bonus_percentage, null: false, default: 0.0
      t.float :bonus_amount, null: false, default: 0.0
      t.float :subtotal, null: false, default: 0.0
      t.string :iva_aliquot
      t.float :iva_amount
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
