class CreateIvaBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :iva_books do |t|
      t.string :tipo
      t.date :date
      t.references :invoice, foreign_key: true
      t.references :company, foreign_key: true
      t.references :purchase_invoice, foreign_key: true
      t.float :net_amount
      t.float :iva_amount
      t.float :total

      t.timestamps
    end
  end
end
