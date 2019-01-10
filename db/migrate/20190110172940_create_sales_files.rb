class CreateSalesFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_files do |t|
      t.references :company, foreign_key: true
      t.references :client, foreign_key: true
      t.bigint :responsable_id
      t.string :observation
      t.date :init_date
      t.date :final_date

      t.timestamps
    end

    add_reference :invoices, :sales_file, foreign_key: true
    add_reference :budgets, :sales_file, foreign_key: true
    add_reference :delivery_notes, :sales_file, foreign_key: true

  end
end
