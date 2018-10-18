class CreateInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :invoices do |t|
      t.boolean :active
      t.references :client, foreign_key: true
      t.string :state
      t.float :total
      t.float :total_pay
      t.string :header_result
      t.string :authorized_on
      t.string :cae_due_date
      t.string :cae
      t.string :cbte_tipo
      t.references :sale_point, foreign_key: true
      t.string :concepto
      t.string :cbte_fch
      t.float :imp_tot_conc
      t.float :imp_op_ex
      t.float :imp_trib
      t.float :imp_neto
      t.float :imp_iva
      t.float :imp_total
      t.integer :cbte_hasta
      t.integer :cbte_desde
      t.string :iva_cond
      t.string :comp_number
      t.references :company, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
