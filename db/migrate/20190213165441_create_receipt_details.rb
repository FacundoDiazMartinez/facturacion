class CreateReceiptDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :receipt_details do |t|
      t.references :receipt, foreign_key: true
      t.references :invoice, foreign_key: true
      t.float :total

      t.timestamps
    end

    remove_column :invoices, :receipt_id
  end
end
